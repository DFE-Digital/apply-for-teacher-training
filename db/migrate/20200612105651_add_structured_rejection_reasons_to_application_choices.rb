class AddStructuredRejectionReasonsToApplicationChoices < ActiveRecord::Migration[6.0]
  def change
    add_column :application_choices, :structured_rejection_reasons, :jsonb
  end
end
