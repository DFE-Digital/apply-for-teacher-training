class AddStatusAndOfferToApplicationChoices < ActiveRecord::Migration[6.0]
  def change
    add_column :application_choices, :status, :integer
    add_column :application_choices, :offer, :json
  end
end
