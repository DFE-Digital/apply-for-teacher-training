class AddDetailsToOfferConditions < ActiveRecord::Migration[7.0]
  def change
    add_column :offer_conditions, :details, :jsonb
  end
end
