ActiveAdmin.register Message do

menu parent: 'wx_msg', priority: 2, label: '微信消息'

permit_params :content, :link, :message_template_id, :ids, to_users: []

controller do
  def new
    # puts '------'
    # puts params[:ids]
    @message = Message.new
    if params[:ids]
      @message.to_users = params[:ids].split(',')
    end
    
    super
  end
end

form do |f|
  f.semantic_errors
  
  f.inputs do
    f.input :message_template_id, as: :select, label: '所属消息模板', required: true, collection: MessageTemplate.where(opened: true).map { |tpl| [tpl.title, tpl.id] }, input_html: { style: 'width: 50%;' },
      prompt: '-- 选择消息模板 --'
    f.input :content, as: :text
    f.input :link, label: '消息链接地址', placeholder: 'http://'
    f.input :to_users, as: :select, label: '消息接收人', multiple: true, placeholder: '选择消息接收者', collection: User.where(verified: true).map { |u| [u.format_nickname, u.id]  }, prompt: '-- 选择消息接收人 --', input_html: { style: 'width: 50%; height: 200px;' }
  end
  
  actions
  
end

end
