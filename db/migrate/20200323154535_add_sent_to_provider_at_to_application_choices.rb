class AddSentToProviderAtToApplicationChoices < ActiveRecord::Migration[6.0]
  def change
    add_column :application_choices, :sent_to_provider_at, :datetime
  end
end
