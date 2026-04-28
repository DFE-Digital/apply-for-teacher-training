class CreateSolidCacheDashboardEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :solid_cache_dashboard_events do |t|
      t.string :event_type, null: false
      t.integer :key_hash, limit: 8, null: false
      t.string :key_string
      t.integer :byte_size, limit: 4
      t.float :duration
      t.datetime :created_at, null: false
      
      t.index [:event_type]
      t.index [:key_hash]
      t.index [:created_at]
    end
  end
end
