class CreateProviders < ActiveRecord::Migration[6.0]
  def change
    create_table :providers do |t|
      t.string :name
      t.string :code

      t.timestamps
    end

    add_index :providers, :code, unique: true
  end
end
