class CreateSiteSettings < ActiveRecord::Migration[6.0]
  def change
    create_table :site_settings do |t|
      t.string :name
      t.text :value
      t.timestamps
    end

    add_index :site_settings, :name, unique: true
  end
end
