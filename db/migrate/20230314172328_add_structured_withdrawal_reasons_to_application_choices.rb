class AddStructuredWithdrawalReasonsToApplicationChoices < ActiveRecord::Migration[7.0]
  def change
    add_column :application_choices, :structured_withdrawal_reasons, :text, array: true, default: []
  end
end
