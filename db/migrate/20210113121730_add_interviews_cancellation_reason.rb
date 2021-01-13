class AddInterviewsCancellationReason < ActiveRecord::Migration[6.0]
  def change
    add_column :interviews, :cancellation_reason, :text
    add_column :interviews, :cancelled_at, :datetime
  end
end
