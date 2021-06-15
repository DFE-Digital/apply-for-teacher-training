class ValidateOffersAndOfferConditionsForeignKeys < ActiveRecord::Migration[6.1]
  def change
    validate_foreign_key 'offers', 'application_choices'
    validate_foreign_key 'offer_conditions', 'offers'
  end
end
