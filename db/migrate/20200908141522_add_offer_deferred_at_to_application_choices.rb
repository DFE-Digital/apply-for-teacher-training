class AddOfferDeferredAtToApplicationChoices < ActiveRecord::Migration[6.0]
  def change
    add_column :application_choices, :offer_deferred_at, :datetime
  end
end
