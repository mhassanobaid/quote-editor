class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :validatable

  belongs_to :company, optional: true

  enum role: { super_admin: 0, company_admin: 1 }

  def self.ransackable_attributes(auth_object = nil)
    [
      "id",
      "email",
      "role",
      "company_id",
      "created_at",
      "updated_at"
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    ["company"]
  end
end
