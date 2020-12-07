class AddOfferChangedAtToApplicationChoice < ActiveRecord::Migration[6.0]
  def change
    add_column :application_choices, :offer_changed_at, :datetime
  end
end
