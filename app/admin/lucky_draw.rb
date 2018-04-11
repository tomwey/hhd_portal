ActiveAdmin.register LuckyDraw do
  
  # menu priority: 16, label: '转盘抽奖'
  
  menu parent: 'cj', priority: 1

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :title, :image, :plate_image, :arrow_image, :background_image, :uid, :location_str, :range, :prize_desc, :memo,
:started_at, :sort, lucky_draw_items_attributes: [:id, :name, :angle, :quantity, :score, :sent_count, :is_virtual_goods, :description, :_destroy]

index do
  selectable_column
  column('ID', :uniq_id)
  column '所有者', sortable: false do |o|
    link_to o.ownerable.try(:format_nickname) || o.ownerable.try(:email), [:cpanel, o.ownerable]
  end
  column :image, sortable: false do |o|
    image_tag o.image.url(:small), size: '64x64'
  end
  column :title, sortable: false
  column '奖项', sortable: false do |o|
    html = ''
    o.lucky_draw_items.each do |item|
      html += "#{item.name}[#{item.uniq_id}]: 中奖概率：#{number_to_percentage((item.score.to_f / o.lucky_draw_items.sum(:score) * 10000 / 100.00), precision: 2)} [#{item.sent_count} / #{item.quantity.blank? ? '不限' : item.quantity}]<br>"
    end
    raw(html)
  end
  column('at', :created_at)
  
  actions defaults: false do |o|
    item "查看", [:cpanel, o]
    
    if not o.opened
    #   item "下架", close_cpanel_redbag_path(o), method: :put
    # else
      item "上架", open_cpanel_lucky_draw_path(o), method: :put, data: { confirm: '您确定吗？' }
    else
      item "下架", close_cpanel_lucky_draw_path(o), method: :put, data: { confirm: '您确定吗？' }
    end
    
    item "编辑", edit_cpanel_lucky_draw_path(o)
    
    # item "删除", cpanel_redbag_path(o), method: :delete, data: { confirm: '你确定吗？' }
  end
  
end

# 上架
batch_action :open do |ids|
  batch_action_collection.find(ids).each do |e|
    e.open!
  end
  redirect_to collection_path, alert: "已上架"
end
member_action :open, method: :put do
  resource.open!
  redirect_to collection_path, notice: '已上架'
end

# 下架
batch_action :close do |ids|
  batch_action_collection.find(ids).each do |e|
    e.close!
  end
  redirect_to collection_path, alert: "已下架"
end
member_action :close, method: :put do
  resource.close!
  redirect_to collection_path, notice: '已下架'
end

form do |f|
  f.semantic_errors
  f.inputs '基本信息' do
    if f.object.new_record? || !f.object.opened
      f.input :uid, as: :select, label: '所有者ID', collection: User.includes(:wechat_profile).where(verified: true).order('id desc').map { |u| ["[#{u.uid}] #{u.format_nickname}", u.uid] }, prompt: '-- 选择所有者 --', required: true, input_html: { style: 'width: 50%;' }
    end
    
    f.input :title
    f.input :image, hint: '尺寸为1080x458，格式为：jpg,png,jpeg,gif'
    f.input :plate_image, hint: '尺寸不限制，但是比例是正方形，格式为：jpg,png,jpeg,gif'
    f.input :prize_desc, as: :text, input_html: { class: 'redactor' }, placeholder: '网页内容，支持图文混排', hint: '网页内容，支持图文混排'
    f.input :arrow_image, hint: '尺寸不限制，但是比例是正方形，格式为：jpg,png,jpeg,gif'
    f.input :background_image, hint: '建议尺寸为1080x1920，格式为：jpg,png,jpeg,gif'
    f.input :sort, hint: '值越小排名越靠前'
  end
  
  f.inputs "多个奖项信息" do
    f.has_many :lucky_draw_items, allow_destroy: true, heading: '奖项信息' do |item_form|
        item_form.input :name
        item_form.input :angle, hint: '转盘旋转一圈是360度，假设转盘旋转10圈停下来，那么此角度需要根据转盘奖项角度设置'
        item_form.input :score, hint: '中奖概率值，是一个整数，如果设置为0，表示不会抽中该奖项'
        item_form.input :quantity, hint: '该奖项可以被抽到的数量，如果不设置，那么可以抽无数次'
        item_form.input :is_virtual_goods, as: :boolean
      # end
    end
  end
  
  f.inputs '选填信息' do
    f.input :location_str, as: :string, label: '抽奖位置', placeholder: '104.123456,30.1234544'
    f.input :range, placeholder: '单位为米'
    f.input :started_at,as: :string, placeholder: '2017-01-01 12:49'
    f.input :memo
  end
  
  actions
end

show do
  attributes_table do
    row :id
    row :uniq_id
    row :ownerable_id
    row :ownerable_type
    row :title
    row :location
    row :range
    row :view_count
    row :share_count
    row :draw_count
    row :started_at
    row :opened
    row :sort
    row :created_at
    row :updated_at
  end
  
  panel "抽奖效果" do
    render 'lucky_draw', lucky_draw: lucky_draw
  end
  
end

end
