class AddRejectByDefaultFeedbackSentAtToApplicationChoices < ActiveRecord::Migration[6.0]
  def change
    add_column :application_choices, :reject_by_default_feedback_sent_at, :datetime
  end
end
