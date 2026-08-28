class ValidateDefferedOfferFk < ActiveRecord::Migration[8.1]
  def change
    validate_foreign_key :deferred_offer_confirmations, :offers
  end
end
