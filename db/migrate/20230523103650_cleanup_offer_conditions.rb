class CleanupOfferConditions < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      remove_column :offer_conditions, :text, :string

      validate_check_constraint :offer_conditions, name: 'offer_conditions_type_not_null'
      change_column_null :offer_conditions, :type, false
      remove_check_constraint :offer_conditions, name: 'offer_conditions_type_not_null'
    end
  end
end
