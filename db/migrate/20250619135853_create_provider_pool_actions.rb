class CreateProviderPoolActions < ActiveRecord::Migration[8.0]
  def change
    create_table :provider_pool_actions do |t|
      t.string :status
      t.references :application_form, null: false, foreign_key: { on_delete: :cascade }
      t.references :actioned_by, null: false, foreign_key: { to_table: :provider_users, on_delete: :cascade }
      t.integer :recruitment_cycle_year

      t.timestamps
    end
  end
end
