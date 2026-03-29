ActiveAdmin.register Company do
  permit_params :name

  # Filters
  filter :name
  filter :created_at

  index do
    column :id
    column :name
    column :created_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
    end
    f.actions
  end
end
