class RemoveOfferFromApplicationChoice < ActiveRecord::Migration[6.0]
  def change
    remove_column :application_choices, :offer, :json
  end
end
