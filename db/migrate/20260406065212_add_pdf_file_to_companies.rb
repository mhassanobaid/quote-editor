class AddPdfFileToCompanies < ActiveRecord::Migration[7.1]
  def change
    add_column :companies, :pdf_file, :string
  end
end
