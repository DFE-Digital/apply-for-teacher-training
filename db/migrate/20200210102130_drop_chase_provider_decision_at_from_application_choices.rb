class DropChaseProviderDecisionAtFromApplicationChoices < ActiveRecord::Migration[6.0]
  def change
    # rubocop:disable Rails/ReversibleMigration
    remove_column :application_choices, :chase_provider_decision_at
    # rubocop:enable Rails/ReversibleMigration
  end
end
