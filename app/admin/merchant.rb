ActiveAdmin.register Merchant do
  
  menu parent: 'merchants', label: '商家管理', priority: 1
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :logo, :name, :auth_type, :opened, :mobile, :address, :tag_name
#
# or
#
index do
  selectable_column
  column('ID', :uniq_id)
  column :logo, sortable: false do |o|
    o.logo.blank? ? '' : image_tag(o.logo.url(:large), size: '60x60')
  end
  column :name, sortable: false 
  column :balance do |o|
    "#{o.balance / 100.00}元"
  end
  column '标签', :tags, sortable: false
  column :auth_type, sortable: false do |o|
    I18n.t("common.merchant.auth_type_#{o.auth_type}")
  end
  column :opened,sortable: false
  column('at', :created_at)
  
  actions
end

show do 
  panel "数据汇总" do
    
    table class: 'stat-table' do
      tr do
        th '余额'
        th '总用户数'
        th '还剩广告个数'
        th '还剩广告金额'
        th '累计发广告个数'
        th '累计发广告金额'
        th '累计被抢金额'
        th '累计浏览次数'
        th '累计参与次数'
        th '累计转发次数'
      end
      tr do
        @total_user ||= merchant.users.count
        @left_count ||= Partin.where(merchant_id: merchant.id).opened.can_take.count
        @left_money ||= Redpack.where(merchant_id: merchant.id, in_use: true).map { |o| o.left_money }.sum / 100.0
        # Partin.where(merchant_id: current_admin_user.merchant_id).opened.map { |o| o.winnable.try(:left_money) }.sum / 100.0
        
        @total_sent_count ||= Partin.where(merchant_id: merchant.id).opened.count
        @total_sent_money ||= Redpack.where(merchant_id: merchant.id, in_use: true).map { |o| o.total_money }.sum / 100.0
        # Partin.where(merchant_id: current_admin_user.merchant_id).opened.map { |o| o.winnable.try(:total_money) }.sum / 100.0
        
        @total_taked_money ||= PartinTakeLog.joins(:partin).where(partins: { merchant_id: merchant.id }).map { |o| (o.resultable.try(:money) || 0) }.sum / 100.0
        
        @total_view_count ||= PartinViewLog.joins(:partin).where(partins: { merchant_id: merchant.id }).count
        @total_take_count ||= PartinTakeLog.joins(:partin).where(partins: { merchant_id: merchant.id }).count
        @total_share_count ||= PartinShareLog.joins(:partin).where(partins: { merchant_id: merchant.id }).count
        td "#{merchant.balance / 100.00}元"
        td @total_user
        td @left_count
        td @left_money
        td @total_sent_count
        td @total_sent_money
        td @total_taked_money
        td @total_view_count
        td @total_take_count
        td @total_share_count
      end
    end # end table
    
    table class: 'stat-table' do
      tr do
        th '今日用户数'
        th '今日发广告个数'
        th '今日发广告金额'
        th '今日被抢金额'
        th '今日浏览次数'
        th '今日参与次数'
        th '今日转发次数'
      end
      
      tr do
        
        @today_user ||= User.joins(:user_merchants).where(user_merchants: { merchant_id: merchant.id, 
          created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day }).count
        #current_admin_user.merchant.users.count
        
        @today_sent_count ||= Partin.where(merchant_id: merchant.id)
          .where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
          .opened.count
        @today_sent_money ||= Partin.where(merchant_id: merchant.id)
          .where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
          .opened.can_take.map { |o| o.winnable.try(:total_money) }.sum / 100.0
        
        @today_taked_money ||= PartinTakeLog.joins(:partin)
          .where(partins: { merchant_id: merchant.id })
          .where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
          .map { |o| (o.resultable.try(:money) || 0) }.sum / 100.0
        
        @today_view_count ||= PartinViewLog.joins(:partin)
          .where(partins: { merchant_id: merchant.id })
          .where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
          .count
        @today_take_count ||= PartinTakeLog.joins(:partin)
          .where(partins: { merchant_id: merchant.id })
          .where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
          .count
        @today_share_count ||= PartinShareLog.joins(:partin)
          .where(partins: { merchant_id: merchant.id })
          .where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).count
        td @today_user
        td @today_sent_count
        td @today_sent_money
        td @today_taked_money
        td @today_view_count
        td @today_take_count
        td @today_share_count
      end
      
    end # end
    
  end
  
  panel "发广告记录" do
    table_for Partin.where(merchant_id: merchant.id).order("id desc") do
      column('ID') { |o| link_to o.uniq_id, [:cpanel, o] }
      column('广告标题') { |o| o.item_id.blank? ? '' : link_to(o.info_item.title, [:cpanel, o.info_item]) }
      column('参与奖励') { |o| o.winnable_id.blank? ? '' : link_to(o.winnable.format_type_name, [:cpanel, o.winnable]) }
      column('参与规则') { |o| o.ruleable_id.blank? ? '' : link_to(o.ruleable.format_type_name, [:cpanel, o.ruleable]) }
      column('状态') { |o| o.can_take ? '有剩余' : '已抢完' }
      column('at', :created_at)
    end
  end
  
  panel "用户分布" do
    view_locations = PartinViewLog.joins(:partin).where(partins: { merchant_id: merchant.id }).where.not(location: nil).pluck(:location)
    earn_locations = PartinTakeLog.joins(:partin).where(partins: { merchant_id: merchant.id }).where.not(location: nil).pluck(:location)
    render '/cpanel/partins/partin_user_map', view_locations: view_locations, earn_locations: earn_locations
  end
  
end

form html: { multipart: true } do |f|
  f.semantic_errors
  f.inputs do
    f.input :name
    f.input :logo, hint: '图片格式为：jpg,jpeg,gif,png'
    f.input :mobile
    # f.input :s_balance, as: :number, label: '余额', placeholder: '单位（元）'
    f.input :address
    f.input :tag_name, as: :string, label: '标签', hint: '用多个标签描述该商家，标签之间用英文逗号分隔', placeholder: '例如：IT,教育,培训'
    f.input :auth_type, as: :select, collection: [['未实名认证', 0], ['实名认证', 1], ['个体户实名认证', 2], ['企业实名认证', 3]]
    f.input :opened, as: :boolean
  end
  actions
end

end
