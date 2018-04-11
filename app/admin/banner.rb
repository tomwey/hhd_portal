ActiveAdmin.register Banner do

menu parent: 'system', priority: 18, label: 'Banner广告'

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :image, :sort, :link, :_link_type, :link_type, :view_count, :click_count, :opened
#
# or

index do
  selectable_column
  column('ID', :uniq_id)
  column :image, sortable: false do |b|
    image_tag b.image.url(:small)
  end
  column '链接类型', sortable: false do |b|
    b.link_type_name
  end
  column '链接对象' do |b|
    b.link
  end
  column :view_count
  column :click_count
  column :opened
  column :sort
  column('at', :created_at)
  
  actions defaults: false do |b|
    item "查看", [:cpanel, b]
    item "编辑", edit_cpanel_banner_path(b, t: b.link_type)
    item "删除", cpanel_banner_path(b), method: :delete, data: { confirm: '你确定吗？' }
  end
end

before_build do |record|
  if request.url.include?('/new') or request.url.include?('/edit')
  # if record._link_type.blank?
    record.link_type = (params[:t] || 0).to_i
  end
  # end
end

form html: { multipart: true } do |f|
  f.semantic_errors
  
  f.inputs '广告基本信息' do
    if f.object.new_record?
      f.input :link_type, as: :select, label: '链接类型', collection: Banner::LINK_TYPES, prompt: '-- 选择广告链接类型 --', input_html: { onchange: "Banner.changeLinkType(this)" }
      # f.input :link_type, as: :hidden, value: 1
      if params[:t]
        if params[:t].to_i == 1
        f.input :link, label: '链接地址', placeholder: 'http://', hint: '需要输入一个绝对的URL地址', required: true
        elsif params[:t].to_i == 2 # 红包广告
        f.input :link, as: :select, label: '设置红包广告', collection: Partin.opened.map { |p| ["[#{p.uniq_id}]#{p.item_title}", "#{p.class}:#{p.id}"] }, prompt: '-- 选择链接的红包广告 --', required: true
        elsif params[:t].to_i == 3 # 优惠券
        f.input :link, as: :select, label: '设置优惠卡', collection: Card.opened.map { |c| ["[#{c.uniq_id}]#{c.title}", "#{c.class}:#{c.id}"] }, prompt: '-- 选择优惠卡 --', required: true
        end
      end
    end
    f.input :image, hint: '图片格式为：jpg,jpeg,gif,png；尺寸为1080x504'
    
    f.input :opened, as: :boolean
    f.input :sort, hint: '值越小排名越靠前'
  end
  # f.inputs '广告统计信息' do
  #   f.input :view_count
  #   f.input :click_count
  # end
  
  actions
  
end

end
