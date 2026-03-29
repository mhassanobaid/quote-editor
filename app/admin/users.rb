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
      f.input :company
      f.input :role
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
