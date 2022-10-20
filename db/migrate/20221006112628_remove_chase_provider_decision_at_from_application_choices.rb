class RemoveChaseProviderDecisionAtFromApplicationChoices < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :application_choices, :chase_provider_decision_at, :datetime, if_exists: true }
  end
end
