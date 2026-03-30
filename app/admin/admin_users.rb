ActiveAdmin.register AdminUser do
  # Strong params
  permit_params :email, :password, :password_confirmation, :role, :company_id

  # Filters
  filter :email
  filter :role
  filter :company
  filter :created_at

  # Index
  index do
    selectable_column
    id_column
    column :email
    column :role
    column :company
    column :created_at
    actions
  end

  # Form (SMART FORM)
  form do |f|
    f.inputs do
      f.input :email

      # Only super admin can assign role
      if current_admin_user.super_admin?
        f.input :role, as: :select, collection: AdminUser.roles.keys
        f.input :company
      else
        # Company admin cannot change role/company
        f.input :role, input_html: { value: f.object.role }, as: :hidden
        f.input :company_id, input_html: { value: current_admin_user.company_id }, as: :hidden
      end

      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  # MULTI-TENANCY + SECURITY
  controller do
    def scoped_collection
      if current_admin_user.super_admin?
        AdminUser.all
      else
        AdminUser.where(company_id: current_admin_user.company_id)
      end
    end

    # Restrict creation
    def create
      if current_admin_user.company_admin?
        params[:admin_user][:company_id] = current_admin_user.company_id
        params[:admin_user][:role] = "company_admin"
      end
      super
    end

    # Restrict update
    def update
      if current_admin_user.company_admin?
        params[:admin_user][:company_id] = current_admin_user.company_id
        params[:admin_user][:role] = "company_admin"
      end
      super
    end
  end
end
