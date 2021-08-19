class AddProviderIdsToApplicationChoices < ActiveRecord::Migration[6.1]
  def change
    add_column :application_choices, :provider_ids, :bigint, array: true, default: []
  end
end
