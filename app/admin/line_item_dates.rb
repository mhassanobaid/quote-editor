ActiveAdmin.register LineItemDate do
  permit_params :quote_id, :date

  includes :quote, :line_items

  filter :date
  filter :quote
  filter :created_at

  index do
    column :id
    column :date
    column("Quote") { |lid| lid.quote.name }
    column("Items Count") { |lid| lid.line_items.size }
    column :created_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :date
      f.input :quote
    end
    f.actions
  end

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
end
