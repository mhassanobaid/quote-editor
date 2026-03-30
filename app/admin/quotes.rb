ActiveAdmin.register Quote do
  # Strong params
  permit_params :name, :company_id

  # Avoid N+1 queries
  includes :company, line_items: :line_item_date

  # Filters
  filter :name
  filter :company
  filter :created_at

  # Index
  index do
    column :id
    column :name
    column :company
    column("Total Price") { |quote| quote.total_price }
    column :created_at
    actions
  end

  # Form
  form do |f|
    f.inputs do
      f.input :name

      # Only super admin can choose company
      if current_admin_user.super_admin?
        f.input :company
      end
    end
    f.actions
  end

  # Show
  show do
    attributes_table do
      row :id
      row :name
      row :company
      row("Total Price") { |quote| quote.total_price }
      row :created_at
    end
  end

  # MULTI-TENANCY + SECURITY
  controller do
    # Handle unauthorized access cleanly
    rescue_from ActiveRecord::RecordNotFound do
      redirect_to admin_quotes_path, alert: "Not authorized"
    end

    # Scope data
    def scoped_collection
      if current_admin_user.super_admin?
        Quote.all
      else
        Quote.where(company_id: current_admin_user.company_id)
      end
    end

    # Prevent URL hacking
    def find_resource
      if current_admin_user.super_admin?
        Quote.find(params[:id])
      else
        Quote.find_by!(
          id: params[:id],
          company_id: current_admin_user.company_id
        )
      end
    end

    # Restrict create
    def create
      if current_admin_user.company_admin?
        params[:quote][:company_id] = current_admin_user.company_id
      end
      super
    end

    # Restrict update
    def update
      if current_admin_user.company_admin?
        params[:quote][:company_id] = current_admin_user.company_id
      end
      super
    end

    # Restrict delete
    def destroy
      if current_admin_user.super_admin?
        super
      else
        if resource.company_id == current_admin_user.company_id
          super
        else
          redirect_to admin_quotes_path, alert: "Not authorized"
        end
      end
    end
  end
end
