module API
  module V1
    class PartinsAPI < Grape::API
      
      helpers API::SharedParams
      resource :partins, desc: '广告参与相关接口' do
        desc "获取广告红包列表"
        params do
          optional :token, type: String, desc: '用户TOKEN'
          optional :loc,   type: String, desc: '位置坐标，格式为：lng,lat'
          use :pagination
        end
        get do
          @user ||= User.find_by(private_token: params[:token])
          
          area_ids = []
          if params[:loc]
            lng,lat = params[:loc].split(',')
            lng = lng || 0
            lat = lat || 0
            
            area_ids = Area.nearby_distance(lng, lat).pluck(:id)
          end
          
          @partins = Partin.opened.for_areas(area_ids).can_take.onlined.sorted.order('partins.updated_at desc')
          
          render_json(@partins, API::V1::Entities::Partin, { user: @user, flag: need_hide_for_ios_approve })
        end # end get /
        
        desc "获取发现的广告"
        params do
          optional :token, type: String, desc: '用户TOKEN'
          optional :loc,   type: String, desc: '位置坐标，格式为：lng,lat'
          use :pagination
        end
        get :explore do
          @user ||= User.find_by(private_token: params[:token])

          @partins = Partin.opened.can_take.onlined.no_location_limit.sorted.order('partins.updated_at desc')
          render_json(@partins, API::V1::Entities::Partin, { user: @user })
        end # end get explore
        
        desc "获取附近的广告"
        params do
          optional :token, type: String, desc: '用户TOKEN'
          requires :lat, type: String, desc: '纬度'
          requires :lng, type: String, desc: '经度'
          # optional :scope, type: Integer, desc: '范围，单位为米'
          # optional :size, type: Integer, desc: '数量'
          use :pagination
        end
        get :nearby do
          # scope = (params[:scope] || 5000).to_i
          # size  = (params[:size] || 20).to_i
          
          @partins = Partin.opened.can_take.onlined.sorted.nearby_distance(params[:lng], params[:lat]).order('partins.updated_at desc, distance asc')#.limit(size)
          
          render_json(@partins, API::V1::Entities::Partin, { user: User.find_by(private_token: params[:token]) })
          # @events = Event.valid.nearby_distance(params[:lng], params[:lat], scope).sorted.order('id desc').limit(size)
          # render_json(@events, API::V1::Entities::Event)
        end # end get nearby
        
        desc "获取广告详情"
        params do
          requires :id,    type: Integer, desc: 'ID'
          optional :token, type: String,  desc: '用户TOKEN'
          optional :loc,   type: String,  desc: '经纬度，用英文逗号分隔，例如：104.213222,30.9088273'
          optional :t,     type: Integer, desc: '是否要记录浏览日志，默认值为1'
        end
        get '/:id/body' do
          @partin = Partin.find_by(uniq_id: params[:id])
          if @partin.blank?
            return render_error(4004, '没有找到数据')
          end
          
          user = User.find_by(private_token: params[:token])
          
          # 写浏览日志
          t = (params[:t] || 1).to_i
          if t == 1
            loc = nil
            if params[:loc]
              loc = params[:loc].gsub(',', ' ')
              loc = "POINT(#{loc})"
            end
            @partin.view_for!(user.try(:id), loc, client_ip, 0, nil) 
          end

          render_json(@partin, API::V1::Entities::PartinDetail, { user: user, flag: need_hide_for_ios_approve })
        end #end get body
        
        desc "获取某个广告的参与记录"
        params do
          requires :id, type: Integer, desc: '红包ID'
          use :pagination
        end
        get '/:id/earns' do
          @partin = Partin.find_by(uniq_id: params[:id])
          if @partin.blank?
            return render_error(4004, '没有找到数据')
          end
          
          @earns = @partin.partin_take_logs.where.not(resultable: nil).order('id desc')
          if params[:page]
            @earns = @earns.paginate page: params[:page], per_page: page_size
            total = @earns.total_entries
          else
            total = @earns.size
          end
          
          render_json(@earns, API::V1::Entities::PartinTakeLog, {}, total)
          
        end # end get earns
        
        desc "获取广告所有者的主页信息"
        params do
          requires :id,    type: Integer, desc: '红包ID'
          optional :token, type: String,  desc: '用户TOKEN'
          optional :loc,   type: String,  desc: '经纬度，用英文逗号分隔，例如：104.213222,30.9088273'
        end 
        get '/:id/owner_timeline' do
          @partin = Partin.includes(:merchant).find_by(uniq_id: params[:id])
          if @partin.blank?
            return render_error(4004, '没有找到数据')
          end
          
          @partin_list = Partin.opened.where(merchant_id: @partin.merchant_id).order('id desc')
          
          @total_sent = @partin_list.size
          @total_earn = 0#@ownerable.try(:earn) || 0.00
          
          { code: 0, message: 'ok', data: { owner: {
            id: @partin.merchant.uniq_id,
            name: @partin.merchant.name,
            logo: @partin.merchant.logo.url(:big),
            auth_type: @partin.merchant.auth_type,
            total_sent: @total_sent,
            total_earn: @total_earn,
          },list: API::V1::Entities::Partin.represent(@partin_list) } }
        end # end get owner_info
        
        desc "浏览奖励广告"
        params do
          optional :token,     type: String, desc: '用户Token'
          optional :from_type, type: Integer, desc: '来源类型'
          optional :loc,       type: String, desc: '经纬度，值用英文逗号分隔，例如：104.321231,90.3218393'
          optional :from_user,  type: String, desc: '分享人TOKEN'
        end
        post '/:id/view' do
          @partin = Partin.includes(:merchant).find_by(uniq_id: params[:id])
          if @partin.blank?
            return render_error(4004, '没有找到数据')
          end
          
          unless @partin.opened
            return render_error(4001, '奖励广告还未上架')
          end
          
          user = User.find_by(private_token: params[:token])
          
          loc = nil
          if params[:loc]
            loc = params[:loc].gsub(',', ' ')
            loc = "POINT(#{loc})"
          end
          
          from_type = ( params[:from_type] || 0 ).to_i
          
          from_user = User.find_by(private_token: params[:from_user])
          from_user_id = from_user.try(:id)
          if from_user_id && from_user_id == user.id
            from_user_id = nil
          end
          
          @partin.view_for!(user.try(:id), loc, client_ip, from_type, from_user_id)  
                             
          render_json_no_data
          
        end # end post view
        
        desc "提交奖励广告"
        params do
          requires :token,   type: String, desc: '用户TOKEN'
          requires :payload, type: JSON,   desc: '活动规则数据, 例如：{ "answer": "dddd" } 或 { "location": "30.12345,104.321234"}'
          optional :from_user, type: String, desc: '分享人的TOKEN'
        end
        post '/:id/commit' do
          user = authenticate!
          
          payload = params[:payload]
          
          @partin = Partin.find_by(uniq_id: params[:id])
          if @partin.blank?
            return render_error(4004, '没有找到数据')
          end
          
          unless @partin.opened
            return render_error(6001, '还没上架，不能参与')
          end
          
          if @partin.online_at && @partin.online_at > Time.zone.now
            return render_error(6001, '还未开始，请耐心等待')
          end
          
          # 判断是否红包还有       
          if not @partin.can_take
            return render_error(6001, '您下手太慢了，已经被抢完了！')
          end
          
          # 检查用户是否已经抢过
          if user.taked?(@partin)
            return render_error(6006, '您已经参与了，不能重复参与')
          end
          
          # 用户位置
          if payload[:location]
            lng,lat = payload[:location].split(',')
            loc = "POINT(#{lng} #{lat})"
          else
            loc = nil
          end
          
          from_user = User.find_by(private_token: params[:from_user])
          from_user_id = from_user.try(:id)
          if from_user_id && from_user_id == user.id
            from_user_id = nil
          end
          
          # 验证参与规则
          ruleable = @partin.ruleable
          if ruleable
            result = ruleable.verify(payload)
            code = result[:code]
            message = result[:message]
            if code.to_i != 0
              if code.to_i == 6003
                # 答案不正确，也记录日志，用户不管对错，只有一次答题的机会
                PartinTakeLog.create!(user_id: user.id, 
                                      partin_id: @partin.id, 
                                      resultable: nil, 
                                      ip: client_ip, 
                                      location: loc,
                                      from_user_id: from_user_id)
              end
              return { code: code, message: message }
            end
          end
          
          # 规则正确
          resultable = @partin.winnable.send_award_to!(user)
          if resultable.blank?
            return render_error(6001, '您下手太慢了，已经被抢完了！')
          end
          
          @log = PartinTakeLog.create!(user_id: user.id, 
                                       partin_id: @partin.id, 
                                       resultable: resultable, 
                                       ip: client_ip, 
                                       location: loc,
                                       from_user_id: from_user_id)
                                       
          unless @partin.winnable.has_left?
            # 没得剩余，将该广告标记为不能参与
            @partin.marked_as_take_done!
          end
          
          # 添加分享人收益
          if from_user_id && from_user_id != user.id
            share_config = @partin.partin_share_config
            if share_config
              winnable = share_config.winnable
              if not winnable.blank?
                # 发分享红包给分享人
                res = winnable.send_award_to!(from_user)
                if res
                  # 发送通知消息给分享人
                  Redpack.send_msg_to_share_user!(res.money, from_user, @partin)
                end
              end
              # winnable.send_award_to!(from_user) unless winnable.blank?
            end
          end
          
          render_json(@log, API::V1::Entities::PartinTakeLog)
        end # end post commit
        
      end # end partins resource
      
    end
  end
end