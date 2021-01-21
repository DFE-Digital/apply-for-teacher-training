class AddTimestampColumnsToTheApplicationReferenceTable < ActiveRecord::Migration[6.0]
  def change
    add_column :references, :feedback_provided_at, :datetime
    add_column :references, :feedback_refused_at, :datetime
    add_column :references, :email_bounced_at, :datetime
    add_column :references, :cancelled_at, :datetime
    add_column :references, :cancelled_at_end_of_cycle_at, :datetime
  end
end
