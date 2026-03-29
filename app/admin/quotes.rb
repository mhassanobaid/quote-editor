ActiveAdmin.register Quote do
  permit_params :name, :company_id

  # Avoid N+1 queries
  includes :company, line_items: :line_item_date

  # Filters (safe only)
  filter :name
  filter :company
  filter :created_at

  # Index page
  index do
    column :id
    column :name
    column :company
    column("Total Price") { |quote| quote.total_price }
    column :created_at
    actions
  end

  # form
  form do |f|
    f.inputs do
      f.input :name
      f.input :company
    end
    f.actions
  end

  # Show page (very useful)
  show do
    attributes_table do
      row :id
      row :name
      row :company
      row("Total Price") { |quote| quote.total_price }
      row :created_at
    end
  end
end
