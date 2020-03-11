class AddDeliveryStatusToEmails < ActiveRecord::Migration[6.0]
  def change
    add_column :emails, :delivery_status, :string, null: false, default: 'unknown'
  end
end
