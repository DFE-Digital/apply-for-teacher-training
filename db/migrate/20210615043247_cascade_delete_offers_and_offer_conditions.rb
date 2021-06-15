class CascadeDeleteOffersAndOfferConditions < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key 'offers', 'application_choices'
    add_foreign_key 'offers', 'application_choices', on_delete: :cascade, validate: false

    remove_foreign_key 'offer_conditions', 'offers'
    add_foreign_key 'offer_conditions', 'offers', on_delete: :cascade, validate: false
  end
end
