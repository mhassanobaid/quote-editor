ActiveAdmin.register LineItemDate do
  # Strong params
  permit_params :quote_id, :date

  # Avoid N+1
  includes :quote, :line_items

  # Filters
  filter :date
  filter :quote
  filter :created_at

  # Index
  index do
    column :id
    column :date
    column("Quote") { |lid| lid.quote.name }
    column("Items Count") { |lid| lid.line_items.size }
    column :created_at
    actions
  end

  # Form
  form do |f|
    f.inputs do
      f.input :date

      # Only super admin can choose any quote
      if current_admin_user.super_admin?
        f.input :quote
      else
        # Company admin → only their company quotes
        f.input :quote,
          collection: Quote.where(company_id: current_admin_user.company_id)
      end
    end
    f.actions
  end

  # Show
  show do
    attributes_table do
      row :id
      row :date
      row("Quote") { |lid| lid.quote.name }
      row :created_at
    end

    panel "Line Items" do
      table_for line_item_date.line_items do
        column :name
        column :quantity
        column :unit_price
        column("Total") { |item| item.total_price }
      end
    end
  end

  # MULTI-TENANCY + SECURITY
  controller do
    # Handle unauthorized access cleanly
    rescue_from ActiveRecord::RecordNotFound do
      redirect_to admin_line_item_dates_path, alert: "Not authorized"
    end

    # Scope data via JOIN (IMPORTANT)
    def scoped_collection
      if current_admin_user.super_admin?
        LineItemDate.all
      else
        LineItemDate.joins(:quote)
                    .where(quotes: { company_id: current_admin_user.company_id })
      end
    end

    # Prevent URL hacking
    def find_resource
      if current_admin_user.super_admin?
        LineItemDate.find(params[:id])
      else
        LineItemDate.joins(:quote)
                    .where(quotes: { company_id: current_admin_user.company_id })
                    .find(params[:id])
      end
    end

    # Restrict create
    def create
      if current_admin_user.company_admin?
        quote = Quote.find_by(
          id: params[:line_item_date][:quote_id],
          company_id: current_admin_user.company_id
        )

        unless quote
          redirect_to admin_line_item_dates_path, alert: "Not authorized"
          return
        end
      end
      super
    end

    # Restrict update
    def update
      if current_admin_user.company_admin?
        quote = Quote.find_by(
          id: params[:line_item_date][:quote_id],
          company_id: current_admin_user.company_id
        )

        unless quote
          redirect_to admin_line_item_dates_path, alert: "Not authorized"
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
          redirect_to admin_line_item_dates_path, alert: "Not authorized"
        end
      end
    end
  end
end
