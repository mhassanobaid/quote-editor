class RenamePdfFileToPdfUrl < ActiveRecord::Migration[7.1]
  def change
    rename_column :companies, :pdf_file, :pdf_url
  end
end
