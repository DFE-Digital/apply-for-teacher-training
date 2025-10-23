class AddOfferedCourseOptionToDeferredOfferConfirmations < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_reference :deferred_offer_confirmations, :offered_course_option, null: false, index: { algorithm: :concurrently }
  end
end
