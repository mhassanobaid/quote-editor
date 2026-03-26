class CreateLineItems < ActiveRecord::Migration[7.1]
  def change
    create_table :line_items do |t|
      t.references :line_item_date, null: false, foreign_key: true
      # added null: false so that even validates: false is done in rails c null never be allowed
      t.string :name, null: false
      t.text :description
      # added null: false //
      t.integer :quantity, null: false
      # added null: false //
      t.decimal :unit_price, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
