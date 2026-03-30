class AddCompanyAndRoleToAdminUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :admin_users, :company, null: true, foreign_key: true
    add_column :admin_users, :role, :integer
  end
end
