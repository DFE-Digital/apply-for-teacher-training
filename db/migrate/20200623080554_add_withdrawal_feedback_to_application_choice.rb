class AddWithdrawalFeedbackToApplicationChoice < ActiveRecord::Migration[6.0]
  def change
    add_column :application_choices, :withdrawal_feedback, :jsonb
  end
end
