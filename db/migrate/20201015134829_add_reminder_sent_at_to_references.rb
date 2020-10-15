class AddReminderSentAtToReferences < ActiveRecord::Migration[6.0]
  def change
    add_column :references, :reminder_sent_at, :datetime
  end
end
