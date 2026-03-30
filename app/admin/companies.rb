ActiveAdmin.register Company do
  permit_params :name

  # Filters
  filter :name
  filter :created_at

  # Index
  index do
    column :id
    column :name
    column :created_at
    actions
  end

  # Form
  form do |f|
    f.inputs do
      f.input :name
    end
    f.actions
  end

  # MULTI-TENANCY LOGIC
  controller do
    rescue_from ActiveRecord::RecordNotFound do
      redirect_to admin_users_path, alert: "Not authorized"
    end

    def scoped_collection
      if current_admin_user.super_admin?
        Company.all
      else
        Company.where(id: current_admin_user.company_id)
      end
    end

    # Prevent accessing other companies via URL
    def find_resource
      if current_admin_user.super_admin?
        Company.find(params[:id])
      else
        Company.where(id: current_admin_user.company_id).find(params[:id])
      end
    end

    # Prevent creating new companies by company admin
    def create
      if current_admin_user.company_admin?
        redirect_to admin_companies_path, alert: "Not authorized"
      else
        super
      end
    end

    # Prevent deleting other companies
    def destroy
      if current_admin_user.super_admin?
        super
      else
        if resource.id == current_admin_user.company_id
          super
        else
          redirect_to admin_companies_path, alert: "Not authorized"
        end
      end
    end
  end
end
