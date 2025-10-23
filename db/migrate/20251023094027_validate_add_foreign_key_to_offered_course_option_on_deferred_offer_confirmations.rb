class ValidateAddForeignKeyToOfferedCourseOptionOnDeferredOfferConfirmations < ActiveRecord::Migration[8.0]
  def change
    validate_foreign_key :deferred_offer_confirmations, :course_options
  end
end
