class AddChaseProviderDecisionAtToApplicationChoices < ActiveRecord::Migration[6.0]
  def change
    add_column :application_choices, :chase_provider_decision_at, :datetime
  end
end
