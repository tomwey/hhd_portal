module API
  module V1
    class CardsAPI < Grape::API
      
      helpers API::SharedParams
      
      resource :cards, desc: '优惠券相关的接口' do
        desc "获取优惠券列表"
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
          
          @cards = Card.opened.for_areas(area_ids).can_send.sorted.order('cards.updated_at desc')
          
          render_json(@cards, API::V1::Entities::Card, { user: @user })
          
        end # end get /
        
        desc "获取优惠券详情"
        params do
          requires :id,    type: Integer, desc: 'ID'
          optional :token, type: String,  desc: '用户TOKEN'
          optional :loc,   type: String,  desc: '经纬度，用英文逗号分隔，例如：104.213222,30.9088273'
        end
        get '/:id/body' do
          @card = Card.find_by(uniq_id: params[:id])
          if @card.blank?
            return render_error(4004, '没有找到数据')
          end
          
          # user = User.find_by(private_token: params[:token])
          
          # 写浏览日志
          # loc = nil
          # if params[:loc]
          #   loc = params[:loc].gsub(',', ' ')
          #   loc = "POINT(#{loc})"
          # end
          # @card.view_for!(user.try(:id), loc, client_ip, 0, nil)

          render_json(@card, API::V1::Entities::CardDetail)
        end #end get body
        
        desc "领取优惠券"
        params do
          requires :token, type: String, desc: '用户认证TOKEN'
          optional :loc,   type: String,  desc: '经纬度，用英文逗号分隔，例如：104.213222,30.9088273'
        end
        post '/:id/take' do
          user = authenticate!
          
          @card = Card.find_by(uniq_id: params[:id])
          if @card.blank?
            return render_error(4004, '没有找到数据')
          end
          
          if user.balance * 100 < @card.price
            return render_error(7001, '余额不足')
          end
          
          if @card.send_to_user2(user)
            render_json_no_data
          else
            render_error(7002, '领取优惠券失败')
          end
        end # end post take
        
        desc "获取我领取的优惠券"
        params do
          requires :token, type: String, desc: '用户认证Token'
          use :pagination
        end
        get :my_list do
          user = authenticate!
          @user_cards = UserCard.includes(:card).where(user_id: user.id).opened.not_used.not_expired
          if params[:page]
            @user_cards = @user_cards.paginate page: params[:page], per_page: page_size
            @total = @user_cards.total_entries
          else
            @total = @user_cards.size
          end
          render_json(@user_cards, API::V1::Entities::UserCard, {}, @total)
        end # end get my_list
        
        desc "获取我领取的某个优惠券详情"
        params do
          requires :token, type: String, desc: '用户认证Token'
          use :pagination
        end
        get 'my_list/:id/body' do
          user = authenticate!
          @user_card = UserCard.includes(:card).where(user_id: user.id, uniq_id: params[:id]).first
          if @user_card.blank?
            return render_error(4004, '未找到该优惠卡')
          end
          
          render_json(@user_card, API::V1::Entities::UserCardDetail)
        end # end get my_list
        
      end # end resource
      
    end # end class
  end
end