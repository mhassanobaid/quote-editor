ActiveAdmin.register User do
  permit_params :email, :company_id, :role, :password, :password_confirmation
  includes :company

  # Only allow safe filters
  filter :email
  filter :company
  filter :created_at

  index do
    column :id
    column :email
    column :company
    column :created_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :email

      # Only super admin can choose company
      if current_admin_user.super_admin?
        f.input :company
      end

      f.input :role
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
  
  controller do
    rescue_from ActiveRecord::RecordNotFound do
      redirect_to admin_users_path, alert: "Not authorized"
    end
    # Scope data
    def scoped_collection
      if current_admin_user.super_admin?
        User.all
      else
        User.where(company_id: current_admin_user.company_id)
      end
    end

    # Prevent URL hacking
    def find_resource
      if current_admin_user.super_admin?
        User.find(params[:id])
      else
        User.where(company_id: current_admin_user.company_id).find(params[:id])
      end
    end

    # Restrict create
    def create
      if current_admin_user.company_admin?
        params[:user][:company_id] = current_admin_user.company_id
      end
      super
    end
    
    # Restrict update
    def update
      if current_admin_user.company_admin?
        params[:user][:company_id] = current_admin_user.company_id
      end
      super
    end

    # Restrict delete (optional but recommended)
    def destroy
      if current_admin_user.super_admin?
        super
      else
        if resource.company_id == current_admin_user.company_id
          super
        else
          redirect_to admin_users_path, alert: "Not authorized"
        end
      end
    end
  end
end
