class CreateFeatures < ActiveRecord::Migration[6.0]
  def change
    create_table :features do |t|
      t.string :name, null: false
      t.boolean :active, default: false, null: false
      t.timestamps
    end

    add_index :features, :name, unique: true
  end
end
