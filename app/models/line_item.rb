class LineItem < ApplicationRecord
  belongs_to :line_item_date

  validates :name, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than: 0 }

  delegate :quote, to: :line_item_date

  def total_price
    quantity * unit_price
  end

  def self.ransackable_attributes(auth_object = nil)
    ["id", "name", "description", "quantity", "unit_price", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["line_item_date"]
  end

  def to_s
    "#{quote.name} - #{date}"
  end
end
