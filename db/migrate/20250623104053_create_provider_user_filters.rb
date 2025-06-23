class CreateProviderUserFilters < ActiveRecord::Migration[8.0]
  def change
    create_table :provider_user_filters do |t|
      t.references :provider_user, null: false, foreign_key: { on_delete: :cascade }
      t.string :path, null: false
      t.integer :pagination_page
      t.jsonb :filters, default: {}
      t.timestamps
    end
  end
end
