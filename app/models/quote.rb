class Quote < ApplicationRecord
  validates :name, presence: true
  scope :ordered, -> { order(id: :desc) }

  # By default, the target option will be equal to model_name.plural, which is equal to "quotes" in the context of our Quote model. Thanks to this convention, we can remove the target: "quotes" option:
  # after_create_commit -> { broadcast_prepend_to "quotes", partial: "quotes/quote", locals: { quote: self } }

=begin
# synchronous so performance will be low
after_create_commit -> { broadcast_prepend_to "quotes" }
after_update_commit -> { broadcast_replace_to "quotes" }
after_destroy_commit -> { broadcast_remove_to "quotes" }
=end

=begin
  after_create_commit -> { broadcast_prepend_later_to "quotes" }
  after_update_commit -> { broadcast_replace_later_to "quotes" }
  # destroy method of broadcast_remove_later_to not exists bcz it is not possible to perform job after quote is deleted
  after_destroy_commit -> { broadcast_remove_to "quotes" }
=end

  # The above three callbacks are equivalent to a single line of code. 
  broadcasts_to ->(quote) { "quotes" }, inserts_by: :prepend
end
