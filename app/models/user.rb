class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :validatable
  enum role: { user: 0, admin: 1 }

  belongs_to :company

  def name
    email.split("@").first.capitalize
  end

  def self.ransackable_attributes(auth_object = nil)
    ["id", "email", "company_id", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["company"]
  end
end
