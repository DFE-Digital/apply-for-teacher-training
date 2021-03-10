class CreateProviderUserNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :provider_user_notifications do |t|
      t.references :provider_user, null: false, foreign_key: { on_delete: :cascade }
      t.boolean :application_received, default: true, null: false
      t.boolean :application_withdrawn, default: true, null: false
      t.boolean :application_rejected_by_default, default: true, null: false
      t.boolean :offer_accepted, default: true, null: false
      t.boolean :offer_declined, default: true, null: false

      t.timestamps
    end
  end
end
