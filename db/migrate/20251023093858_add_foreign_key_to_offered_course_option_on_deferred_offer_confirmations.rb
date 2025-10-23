class AddForeignKeyToOfferedCourseOptionOnDeferredOfferConfirmations < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :deferred_offer_confirmations, :course_options, column: :offered_course_option_id, validate: false
  end
end
