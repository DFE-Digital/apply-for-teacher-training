class AddTypeToOfferConditions < ActiveRecord::Migration[7.0]
  def change
    add_column :offer_conditions, :type, :string
  end
end
