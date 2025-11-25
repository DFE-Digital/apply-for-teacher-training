class CreateNotifySendRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :notify_send_requests do |t|
      t.string :template_id, null: false
      t.string :email_addresses, array: true
      t.references :support_user, null: false
      t.timestamps
    end
  end
end
