ActiveAdmin.register Hongbao do
  
  # menu parent: 'events', priority: 2
  menu false

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :_type, :total_money, :min_value, :max_value, :value, :num, :use_type
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

index do
  selectable_column
  column('ID', :uniq_id)
  column :total_money
  column '红包类型', sortable: false do |hb|
    hb._type == 0 ? '随机红包' : '固定红包'
  end
  column '红包用途', sortable: false do |hb|
    hb.use_type_info
  end
  column :min_value
  column :max_value
  column '所属活动', sortable: false do |hb|
    if hb.event.blank?
      '未绑定到活动'
    else
      hb.event.title
    end
  end
  column '是否是代发', sortable: false do |hb|
    hb.operator_type == 'Admin' ? '是' : '否'
  end
  column :created_at
  actions
  
end

form do |f|
  f.semantic_errors
  
  f.inputs do
    if f.object.event_id.blank?
      f.input :use_type, as: :select, label: '红包用途', collection: Hongbao.all_use_types, prompt: '-- 选择红包用途 --', required: true
    end
    f.input :_type, as: :select, collection: [['随机红包', 0], ['固定红包', 1]], prompt: '-- 选择红包类型 --', input_html: { id: 'hb-type' }
    f.input :total_money
    f.input :min_value
    f.input :max_value
    f.input :num, required: true
    f.input :value, required: true
  end
  actions
  
end

end
# ActiveAdmin.register Hongbao do
# 
# # See permitted parameters documentation:
# # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
# #
# permit_params :_type, :total_money, :min_value, :max_value, :value, :num, :use_type, :hb_type, :rule_type, :location_str, :range, :started_at
# #
# # or
# #
# # permit_params do
# #   permitted = [:permitted, :attributes]
# #   permitted << :other if params[:action] == 'create' && current_user.admin?
# #   permitted
# # end
# 
# index do
#   selectable_column
#   column('ID', :uniq_id)
#   column :total_money
#   column '红包类型', sortable: false do |hb|
#     hb._type == 0 ? '随机红包' : '固定红包'
#   end
#   column '红包用途', sortable: false do |hb|
#     hb.use_type_info
#   end
#   column :min_value
#   column :max_value
#   column '红包内容', sortable: false do |hb|
#     if hb.hbable
#       link_to hb.hbable.try(:title) || "#{hb.hbable.class} - #{hb.hbable.id}", [:cpanel, hb.hbable]
#     else
#       ''
#     end
#   end
#   column '红包规则', sortable: false do |hb|
#     if hb.ruleable
#       if hb.ruleable_type == 'Question'
#         raw("答题类活动<br>题目：#{hb.ruleable.question}<br>答案：#{hb.ruleable.answers[hb.ruleable.answer.to_i]}")
#       elsif hb.ruleable_type == 'LocationCheckin'
#         raw("签到类活动<br>签到地址：#{hb.ruleable.address}<br>允许误差：#{hb.ruleable.accuracy}米")
#       else
#         '未知规则'
#       end
#     else
#       ''
#     end
#     # if hb.ruleable_type == 'Question' && e.ruleable.present?
#     #   raw("答题类活动<br>题目：#{e.ruleable.question}<br>答案：#{e.ruleable.answers[e.ruleable.answer.to_i]}")
#     # elsif e.ruleable_type == 'CheckinRule'&& e.ruleable.present?
#     #   raw("签到类活动<br>签到地址：#{e.ruleable.address}<br>允许误差：#{e.ruleable.accuracy}米")
#     # else
#     #   '-'
#     # end
#   end
#   column '是否是代发', sortable: false do |hb|
#     hb.operator_type == 'Admin' ? '是' : '否'
#   end
#   column :created_at
#   actions
#   
# end
# 
# form do |f|
#   f.semantic_errors
#   
#   f.inputs '红包基本信息' do
#     f.input :hb_type, as: :select, label: '红包内容', collection: Hongbao.hb_types, include_blank: '---------', prompt: '-- 选择红包内容 --'
#     f.input :_type, as: :select, collection: [['随机红包', 0], ['固定红包', 1]], prompt: '-- 选择红包类型 --', input_html: { id: 'hb-type' }
#     f.input :total_money
#     f.input :min_value
#     f.input :max_value
#     f.input :num, required: true
#     f.input :value, required: true
#     f.input :rule_type, as: :select, label: '红包规则', collection: Hongbao.rule_types, include_blank: '---------', prompt: '-- 选择红包规则 --'
#   end
#   f.inputs '选填信息' do
#     f.input :location_str, label: '红包位置坐标', placeholder: '输入经纬度坐标，例如：104.039393,90.9484921'
#     f.input :range, label: '限制范围', hint: '单位为米'
#     f.input :started_at, label: '开抢时间', as: :string, placeholder: '2017-09-09 12:09'
#   end
#   actions
#   
# end
# 
# end
