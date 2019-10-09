class AddOfferConditionsToApplicationChoice < ActiveRecord::Migration[6.0]
  def change
    add_column :application_choices, :offer_conditions, :string, array: true, default: []
  end
end
