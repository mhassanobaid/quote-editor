class Company < ApplicationRecord
  validates :name, presence: true

  has_many :users, dependent: :destroy
  has_many :quotes, dependent: :destroy

  def self.ransackable_attributes(auth_object = nil)
    ["id", "name", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["users", "quotes"]
  end
end
