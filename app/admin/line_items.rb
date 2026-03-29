ActiveAdmin.register LineItem do
  permit_params :line_item_date_id, :name, :description, :quantity, :unit_price

  includes line_item_date: :quote

  filter :name
  filter :line_item_date
  filter :quantity
  filter :unit_price
  filter :created_at

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

  form do |f|
    f.inputs do
      f.input :line_item_date
      f.input :name
      f.input :description
      f.input :quantity
      f.input :unit_price, input_html: { min: 0.01 }
    end
    f.actions
  end

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
end
