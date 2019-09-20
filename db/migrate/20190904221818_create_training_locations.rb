class CreateTrainingLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :training_locations do |t|
      t.integer :provider_id, null: false
      t.timestamps
    end
  end
end
