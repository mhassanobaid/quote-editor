ActiveAdmin.register LineItem do
  # Strong params
  permit_params :line_item_date_id, :name, :description, :quantity, :unit_price

  # Avoid N+1
  includes line_item_date: :quote

  # Filters
  filter :name
  filter :line_item_date
  filter :quantity
  filter :unit_price
  filter :created_at

  # Index
  index do
    column :id
    column :name
    column("Quote") { |item| item.quote.name }
    column("Date") { |item| item.line_item_date.date }
    column :quantity
    column :unit_price
    column("Total") { |item| item.total_price }
    column :created_at
    actions
  end

  # Form
  form do |f|
    f.inputs do
      # Super admin → all dates
      if current_admin_user.super_admin?
        f.input :line_item_date
      else
        # Company admin → only their company dates
        f.input :line_item_date,
          collection: LineItemDate.joins(:quote).where(quotes: { company_id: current_admin_user.company_id })
      end

      f.input :name
      f.input :description
      f.input :quantity
      f.input :unit_price, input_html: { min: 0.01 }
    end
    f.actions
  end

  # Show
  show do
    attributes_table do
      row :id
      row :name
      row :description
      row("Quote") { |item| item.quote.name }
      row("Date") { |item| item.line_item_date.date }
      row :quantity
      row :unit_price
      row("Total") { |item| item.total_price }
      row :created_at
    end
  end

  # MULTI-TENANCY + SECURITY
  controller do
    # Graceful handling
    rescue_from ActiveRecord::RecordNotFound do
      redirect_to admin_line_items_path, alert: "Not authorized"
    end

    # cope data (IMPORTANT JOIN)
    def scoped_collection
      if current_admin_user.super_admin?
        LineItem.all
      else
        LineItem.joins(line_item_date: :quote).where(quotes: { company_id: current_admin_user.company_id })
      end
    end

    # Prevent URL hacking
    def find_resource
      if current_admin_user.super_admin?
        LineItem.find(params[:id])
      else
        LineItem.joins(line_item_date: :quote).where(quotes: { company_id: current_admin_user.company_id }).find(params[:id])
      end
    end

    # Restrict create
    def create
      if current_admin_user.company_admin?
        lid = LineItemDate.joins(:quote).where(quotes: { company_id: current_admin_user.company_id }).find_by(id: params[:line_item][:line_item_date_id])

        unless lid
          redirect_to admin_line_items_path, alert: "Not authorized"
          return
        end
      end
      super
    end

    # Restrict update
    def update
      if current_admin_user.company_admin?
        lid = LineItemDate.joins(:quote).where(quotes: { company_id: current_admin_user.company_id }).find_by(id: params[:line_item][:line_item_date_id])

        unless lid
          redirect_to admin_line_items_path, alert: "Not authorized"
          return
        end
      end
      super
    end

    # Restrict delete
    def destroy
      if current_admin_user.super_admin?
        super
      else
        if resource.quote.company_id == current_admin_user.company_id
          super
        else
          redirect_to admin_line_items_path, alert: "Not authorized"
        end
      end
    end
  end
end
