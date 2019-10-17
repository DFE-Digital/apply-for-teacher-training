class CreateSites < ActiveRecord::Migration[6.0]
  def change
    create_table :sites do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.references :provider, null: false, foreign_key: true

      t.timestamps
    end

    add_index :sites, %i[code provider_id], unique: true
  end
end
