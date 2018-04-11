ActiveAdmin.register Event do

# menu parent: 'events', priority: 1
menu false

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :title, :image, :body, :body_url, :location_str, :range, :started_at, :sort, :uid, :share_hb_id,
  :rule_type, :question, :_answers, :answer, :address, :accuracy, :checkined_at, :current_hb_id#, { hongbao_attributes: [:_type, :total_money, :min_value, :max_value, :value, :num] }

#

index do
  selectable_column
  column('ID', :uniq_id)
  column :image, sortable: false do |e|
    image_tag e.image.url(:small)
  end
  column(:title, sortable: false)
  column '红包信息', sortable: false do |e|
    if e.current_hb.blank?
      '—'
    else
      raw("红包类型：#{e.current_hb._type == 0 ? '随机红包': '固定红包'}<br>红包金额：#{e.current_hb.total_money}<br>红包大小：#{e.current_hb._type == 1 ? e.current_hb.min_value : e.current_hb.min_value.to_s + '~' + e.current_hb.max_value.to_s}<br>剩余金额：#{e.current_hb.total_money - e.current_hb.sent_money}")
    end
  end
  column '分享红包信息', sortable: false do |e|
    if e.share_hb.blank?
      '—'
    else
      raw("红包类型：#{e.share_hb._type == 0 ? '随机红包': '固定红包'}<br>红包金额：#{e.share_hb.total_money}<br>红包大小：#{e.share_hb._type == 1 ? e.share_hb.min_value : e.share_hb.min_value.to_s + '~' + e.share_hb.max_value.to_s}<br>剩余金额：#{e.share_hb.total_money - e.share_hb.sent_money}")
    end
  end
  
  column '活动规则', sortable: false do |e|
    if e.ruleable_type == 'QuizRule' && e.ruleable.present?
      raw("答题类活动<br>题目：#{e.ruleable.question}<br>答案：#{e.ruleable.answers[e.ruleable.answer.to_i]}")
    elsif e.ruleable_type == 'CheckinRule'&& e.ruleable.present?
      raw("签到类活动<br>签到地址：#{e.ruleable.address}<br>允许误差：#{e.ruleable.accuracy}米")
    else
      '-'
    end
  end
  column '所有者', sortable: false do |e|
    link_to e.ownerable.try(:format_nickname), cpanel_user_path(e.ownerable)
  end
  column '发布时间', :created_at 
  
  actions defaults: false do |o|
    item "查看", cpanel_event_path(o)
    if o.can_approve?
      item "审核", approve_cpanel_event_path(o), method: :put
    end
    if o.can_reject?
      item "拒绝", reject_cpanel_event_path(o), method: :put
    end
    item "编辑", edit_cpanel_event_path(o)
    item "删除", cpanel_event_path(o), method: :delete, data: { confirm: '你确定吗？' }
  end
  
end

# 审核
batch_action :approve do |ids|
  batch_action_collection.find(ids).each do |e|
    e.approve
  end
  redirect_to collection_path, alert: "审核通过！"
end
member_action :approve, method: :put do
  resource.approve
  redirect_to collection_path, notice: '审核通过！'
end

# 审核不通过
batch_action :reject do |ids|
  batch_action_collection.find(ids).each do |e|
    e.reject
  end
  redirect_to collection_path, alert: "审核未通过！"
end
member_action :reject, method: :put do
  resource.reject
  redirect_to collection_path, notice: '审核未通过！'
end

before_create do |event|
  
  user = User.find_by(uid: event.uid)
  
  # event.ownerable = current_admin
  event.ownerable = user
  
  if event.rule_type.present?
    if event.rule_type == 'quiz'
      ruleable = QuizRule.create!(question: event.question, answers: event._answers.split(','), answer: event.answer)
    elsif event.rule_type == 'checkin'
      ruleable = CheckinRule.create!(address: event.address, accuracy: event.accuracy, checkined_at: event.checkined_at)
    end
    # puts ruleable
    
    event.ruleable = ruleable
  end
end

after_create do |event|
  if event.ruleable
    event.ruleable.event_id = event.uniq_id
    event.ruleable.save!
  end
  
  money = 0.0
  if event.current_hb
    event.current_hb.event_id = event.id
    event.current_hb.operator_type = current_admin.class.to_s
    event.current_hb.operator_id   = current_admin.id
    event.current_hb.save!
    
    money += event.current_hb.total_money
  end
  
  if event.share_hb
    event.share_hb.event_id = event.id
    event.share_hb.operator_type = current_admin.class.to_s
    event.share_hb.operator_id   = current_admin.id
    event.share_hb.save!
    
    money += event.share_hb.total_money
  end
  
  if money > 0.0 && event.ownerable_type == 'User'
    user = event.ownerable
    user.balance -= money
    if user.balance < 0.0
      user.balance = 0.0
    end
    user.save!
  end
  
  
end

show do 
  render 'event_body', { event: event }
end

form html: { multipart: true } do |f|
  f.semantic_errors
  
  f.inputs '活动基本信息' do
    if f.object.new_record?
    f.input :uid, label: '所属用户', required: true
    end
    f.input :title, placeholder: '输入主题'
    f.input :image, hint: '图片格式为：jpg,jpeg,gif,png'
    f.input :body, as: :text, input_html: { class: 'redactor' }, placeholder: '网页内容，支持图文混排', hint: '网页内容，支持图文混排'
    if f.object.new_record?
    f.input :current_hb_id, as: :select, label: '参与红包', collection: Hongbao.where(event_id: nil, use_type: Hongbao::USE_TYPE_BASE).order('id desc').map { |hb| ["#{hb._type == 0 ? '随机红包' : '固定红包'}: #{hb.total_money}, #{hb._type == 0 ? hb.min_value.to_s + '~' + hb.max_value.to_s : hb.min_value}", hb.uniq_id] },prompt: '-- 选择参与红包 --', required: true
    f.input :share_hb_id, as: :select, label: '分享红包', collection: Hongbao.where(event_id: nil, use_type: Hongbao::USE_TYPE_SHARE).order('id desc').map { |hb| ["#{hb._type == 0 ? '随机红包' : '固定红包'}: #{hb.total_money}, #{hb._type == 0 ? hb.min_value.to_s + '~' + hb.max_value.to_s : hb.min_value}", hb.uniq_id] },prompt: '-- 选择分享红包 --'
    f.input :rule_type, as: :select, label: '活动规则', collection: [['题目类活动规则', 'quiz'], ['签到类活动规则', 'checkin']], prompt: '-- 选择活动规则类型 --', input_html: { id: 'rule-type' }, required: true
    end
        
    f.input :sort
  end
  # f.has_many :hongbao, for: [:hongbao, f.object.hongbao || Hongbao.new] do |hb_form|
  #   hb_form.input :_type, as: :select, collection: [['随机红包', 0], ['固定红包', 1]], prompt: '-- 选择红包类型 --', input_html: { id: 'hb-type' }
  #   hb_form.input :total_money
  #   hb_form.input :min_value
  #   hb_form.input :max_value
  #   hb_form.input :num, required: true
  #   hb_form.input :value, required: true
  # end
  
  # f.inputs '题目类活动规则', id: 'quiz-rule', for: [:ruleable, f.object.ruleable || ( QuizRule.new  )] do |rule_form|
  #   rule_form.input :question, label: '题目问题', hint: '题目问题的答案能够从活动内容中找到'
  #   rule_form.input :_answers, label: '题目答案选项', hint: '值为英文逗号连接的字符串数组，例如：4,5,6'
  #   rule_form.input :answer, label: '正确答案', hint: '正确答案为答案选项的索引值'
  # end
  
  f.inputs '题目类活动规则', id: 'quiz-rule' do
    f.input :question, label: '题目问题', hint: '题目问题的答案能够从活动内容中找到'
    f.input :_answers, label: '题目答案选项', hint: '值为英文逗号连接的字符串数组，例如：4,5,6'
    f.input :answer, label: '正确答案', hint: '正确答案为答案选项的索引值'
  end
  
  f.inputs '签到类活动规则', id: 'checkin-rule' do
    f.input :address, label: '签到地址', hint: '为了能正确解析该地址，需要输入完整的详细地址。例如：成都市金牛区韦家碾一路2号'
    f.input :accuracy, label: '允许的签到位置误差值(单位为米)'
    f.input :checkined_at, label: '签到截止时间', hint: '时间格式为：yyyy-MM-dd HH:mm；例如：2017-09-01 19:00'
  end
  
  f.inputs '选填信息' do
    f.input :location_str, placeholder: '输入详细的地址，例如：成都市金牛区绿地世纪城', hint: '输入地址，系统自动解析'
    f.input :range, placeholder: '活动范围'
    f.input :started_at, as: :string, placeholder: '例如：2017-01-10 18:00'
    f.input :body_url, placeholder: '可选', hint: '此字段用作保留字段'
  end
  
  actions
end


end