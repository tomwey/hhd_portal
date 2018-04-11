ActiveAdmin.register OfferwallChannel do
  
  menu parent: 'offerwall', priority: 1

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :name, :icon, :appid, :app_secret, :platform, :server_secret, :task_url, :opened, :sort, :req_sig_method, :resp_sig_method, :success_return, :failure_return
#

index do
  selectable_column
  column('ID', :uniq_id)
  column :name, sortable: false
  column 'ICON', sortable: false do |o|
    o.icon.blank? ? '' : image_tag(o.icon.url(:small))
  end
  column :platform, sortable: false
  column '渠道信息', sortable: false do |o|
    raw("应用ID: #{o.appid}<br>应用密钥: #{o.app_secret}<br>服务器密钥: #{o.server_secret}<br>接口签名方法: #{o.req_sig_method}<br>回调签名方法: #{o.resp_sig_method}<br>处理成功返回: #{o.success_return}<br>验证失败返回: #{o.failure_return}")
  end
  
  column :opened, sortable: false
  column :sort
  column('at', :created_at)
  
  actions
end


form html: { multipart: true } do |f|
  f.semantic_errors
  f.inputs '基本信息' do
    # f.input :mobile
    f.input :name
    f.input :icon, as: :file, hint: '图片格式为：jpg,jpeg,png,gif'
    f.input :platform, as: :select, label: '平台', collection: ['iOS', 'Android'], prompt: '-- 选择平台 --',input_html: { style: 'width: 240px;' }
    f.input :appid
    f.input :app_secret
    f.input :server_secret
    f.input :opened, label: '是否打开'
    f.input :sort
  end

  f.inputs '渠道信息' do
    f.input :task_url
    f.input :req_sig_method
    f.input :resp_sig_method
    f.input :success_return
    f.input :failure_return
  end
  
  actions
  
end

end
