ActiveAdmin.register AdminUser do
  
  menu parent: 'merchants', label: '账号管理', priority: 2
  
  permit_params :email, :password, :password_confirmation, :merchant_id
  
  config.filters = false
  
  controller do
    def update_resource(object, attributes)
      update_method = attributes.first[:password].present? ? :update_attributes : :update_without_password
      object.send(update_method, *attributes)
    end
  end

  actions :all, except: [:show]
  
  index do
    selectable_column
    column 'ID', :id
    column '所属商家', sortable: false do |o|
      o.merchant_id.blank? ? '' : link_to(o.merchant.try(:name), [:cpanel, o.merchant])
    end
    column :email, sortable: false
    # column '角色', sortable: false do |admin|
    #   admin.role_name
    # end
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end
  
  form do |f|
    f.semantic_errors
    f.inputs "账号信息" do
      f.input :merchant_id, as: :select, label: '所属商家', 
        collection: Merchant.where(opened: true).order('id desc').map{ |o| [o.name, o.id] }, 
        prompt: '-- 选择所属商家 --'
      if f.object.new_record?
        f.input :email
      end
      f.input :password
      f.input :password_confirmation
      # f.input :role, as: :radio, collection: Admin.roles.map { |role| [I18n.t("common.#{role}"), role] }
    end
    f.actions
  end

end
