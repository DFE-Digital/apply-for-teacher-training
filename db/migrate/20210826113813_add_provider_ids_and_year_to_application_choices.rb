class AddProviderIdsAndYearToApplicationChoices < ActiveRecord::Migration[6.1]
  def change
    add_column :application_choices, :provider_ids, :bigint, array: true, default: []
    add_column :application_choices, :current_recruitment_cycle_year, :int
  end
end
