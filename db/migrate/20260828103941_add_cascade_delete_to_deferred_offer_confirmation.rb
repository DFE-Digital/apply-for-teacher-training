class AddCascadeDeleteToDeferredOfferConfirmation < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :deferred_offer_confirmations, :offers
    add_foreign_key :deferred_offer_confirmations, :offers, on_delete: :cascade, validate: false
  end
end
