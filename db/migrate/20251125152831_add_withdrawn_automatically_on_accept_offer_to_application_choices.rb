class AddWithdrawnAutomaticallyOnAcceptOfferToApplicationChoices < ActiveRecord::Migration[8.0]
  def change
    add_column :application_choices, :withdrawn_automatically_on_accept_offer, :boolean
  end
end
