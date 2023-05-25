class PrepareCleanupOfferConditions < ActiveRecord::Migration[7.0]
  def change
    add_check_constraint :offer_conditions, 'type IS NOT NULL', name: 'offer_conditions_type_not_null', validate: false
  end
end
