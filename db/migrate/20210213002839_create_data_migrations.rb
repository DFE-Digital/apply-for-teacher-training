class CreateDataMigrations < ActiveRecord::Migration[6.0]
  def change
    create_table :data_migrations do |t|
      t.string :service_name
      t.string :timestamp

      t.timestamps
    end
    add_index :data_migrations, %i[service_name timestamp], unique: true
  end
end
