ActiveAdmin.register Redpack do
  menu parent: 'merchants', label: '红包', priority: 7
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#

config.filters = false

# permit_params :_type, :money, :is_cash, :total_count, :min_money,
  # redpack_send_config_attributes: [:id, :send_name, :wishing, :act_name, :remark, :scene_id, :_destroy]
#
# or
index do
  selectable_column
  column 'ID', :uniq_id, sortable: false
  column '所属商家', sortable: false do |o|
    link_to o.merchant.name, [:cpanel, o.merchant]
  end
  column '红包类型', sortable: false do |o|
    o._type == 0 ? '拼手气红包' : '普通红包'
  end
  column '红包用途', sortable: false do |o|
    o.use_type == 0 ? '广告红包' : '分享红包'
  end
  column '总金额' do |o|
    "#{o.total_money / 100.0}"
  end
  column '发出金额' do |o|
    "#{o.sent_money / 100.0}"
  end
  column '红包个数', :total_count
  column '发出个数', :sent_count
  column '是否是现金红包', sortable: false do |o|
    o.is_cash ? '现金红包' : '非现金红包'
  end
  column '使用状态', sortable: false do |o|
    o.in_use ? '使用中' : '未使用'
  end
  column '红包最小值' do |o|
    "#{((o.min_value || 5) / 100.0)}元"
  end
  column 'at', :created_at
  
  # actions
end



# before_create do |o|
#   o.merchant = current_admin_user.merchant
# end
#
# form html: { multipart: true } do |f|
#   f.semantic_errors
#   f.inputs '基本信息' do
#     if f.object.new_record?
#     f.input :_type, as: :radio, collection: [['拼手气红包', 0], ['普通红包', 1]], required: true,
#       input_html: { onchange: 'Redpack.changeType(this)' }
#     else
#       f.input :_type, as: :radio, collection: [['拼手气红包', 0], ['普通红包', 1]], required: true,
#         input_html: { onchange: 'Redpack.changeType(this)',
#         data: { total_money: "#{f.object.try(:total_money)}", total_count: "#{f.object.try(:total_count)}" } }
#     end
#     f.input :use_type, as: :select, label: '用途', collection: Redpack::USE_TYPES, required: true
#       #data: { total_money: "#{f.object.try(:total_money)}", total_count: "#{f.object.try(:total_count)}" }
#     if f.object.new_record? or f.object._type == 0
#       f.input :money, as: :number, label: "总金额"
#     else
#       f.input :money, as: :number, label: "单个金额"
#     end
#     f.input :total_count, as: :number, label: '红包个数'
#     f.input :min_money, as: :number, label: '最小值', placeholder: '普通红包可不填，拼手气红包可以设置一个抢红包最低金额，默认为0.05元',
#        hint: '拼手气红包可以指定一个最小值，如果不设置默认为0.05元；另：如果是发现金红包，那么该值最低不能小于1元'
#     f.input :is_cash, as: :boolean, input_html: { onchange: 'Redpack.toggleCashHB(this)' }
#   end
#
#   f.inputs "微信现金红包配置",
#     data: { is_cash: "#{(f.object.new_record? || f.object.is_cash == false) ? '0' : '1'}" },
#     id: 'redpack-send-configs',
#     for: [:redpack_send_config, (f.object.redpack_send_config || RedpackSendConfig.new)] do |s|
#     s.input :send_name, placeholder: "#{current_admin_user.merchant.name}（可选，如果不设置，默认为商家的名称）"
#     s.input :wishing, placeholder: '恭喜发财，大吉大利（可选）'
#     # s.input :act_name
#     # s.input :remark
#     # s.input :scene_id, as: :select, collection: Redpack.wx_send_scenes,
#       # prompt: '-- 选择红包发送场景 --',input_html: { style: 'width: 240px;' }
#   end
#
#   actions
# end

end
