class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :notified, polymorphic: true, null: false
      t.string :notification_type, null: false

      t.timestamps
    end
  end
end
