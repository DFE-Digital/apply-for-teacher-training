class RemoveOfferFromApplicationChoice < ActiveRecord::Migration[6.1]
  def change
    safety_assured { remove_column :application_choices, :offer, :jsonb }
  end
end
