class LineItemDate < ApplicationRecord
  belongs_to :quote
  has_many :line_items, dependent: :destroy

  validates :date, presence: true, uniqueness: { scope: :quote_id }

  scope :ordered, -> { order(date: :asc) }

  def previous_date
    quote.line_item_dates.ordered.where("date < ?", date).last
  end

  def self.ransackable_attributes(auth_object = nil)
    ["id", "date", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["quote", "line_items"]
  end

  def to_s
  "#{quote.name} - #{date}"
  end
end
