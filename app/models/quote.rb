class Quote < ApplicationRecord
  validates :name, presence: true
  scope :ordered, -> { order(id: :desc) }

  # By default, the target option will be equal to model_name.plural, which is equal to "quotes" in the context of our Quote model. Thanks to this convention, we can remove the target: "quotes" option:
  # after_create_commit -> { broadcast_prepend_to "quotes", partial: "quotes/quote", locals: { quote: self } }

  after_create_commit -> { broadcast_prepend_to "quotes" }
  after_update_commit -> { broadcast_replace_to "quotes" }
  after_destroy_commit -> { broadcast_remove_to "quotes" }
end
