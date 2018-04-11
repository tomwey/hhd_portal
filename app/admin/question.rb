ActiveAdmin.register Question do
  
  menu parent: 'hb_events', priority: 2, label: '题目规则'

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :question, :answer, :answers_str, :memo


form do |f|
  f.semantic_errors
  
  f.inputs do
    f.input :question
    f.input :answers_str, label: '答案选项', required: true
    f.input :answer
    f.input :memo
  end
  
  actions
end


end
