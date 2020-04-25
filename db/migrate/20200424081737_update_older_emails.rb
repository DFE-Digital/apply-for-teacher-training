class UpdateOlderEmails < ActiveRecord::Migration[6.0]
  def up
    skipped = Email.pending.where('emails.to LIKE ?', '%example%')
    skipped.update_all(delivery_status: 'skipped')

    emails_during_notify_incident = Email.pending.where(updated_at: DateTime.parse('2020-04-21 17:00:00')..DateTime.parse('2020-04-21 23:59:00'))
    emails_during_notify_incident.update_all(delivery_status: 'notify_error')
  end

  def down; end
end
