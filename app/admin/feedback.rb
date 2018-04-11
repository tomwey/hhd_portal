ActiveAdmin.register Feedback do

menu parent: 'other_func', priority: 20, label: '意见反馈'

index do
  selectable_column
  column('ID', :id)
  column '用户', sortable: false do |f|
    if f.user.blank?
      ''
    else
      link_to user.uid, cpanel_user_path(user)
    end
  end
  column '内容', sortable: false do |f|
    f.content
  end
  column '联系方式', sortable: false do |f|
    f.author
  end
  column '附件图片', sortable: false do |f|
    if f.attachments.any?
      html = ''
      f.attachments.each do |attachment|
        a = '<a href="' + "#{attachment.data.url}" + '">'+ "#{attachment.data_file_name}" +'</a><br>'
        html += a
      end
      raw(html)
    else
      ''
    end
  end
  column('at', :created_at)
  actions
end

end
