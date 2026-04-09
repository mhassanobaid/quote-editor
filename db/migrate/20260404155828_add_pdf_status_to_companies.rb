class AddPdfStatusToCompanies < ActiveRecord::Migration[7.1]
  def change
    add_column :companies, :pdf_status, :string
  end
end
