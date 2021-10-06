class AddUnsubscribedBooleanToCandidate < ActiveRecord::Migration[6.1]
  def change
    add_column :candidates, :unsubscribed_from_emails, :boolean, default: false
  end
end
