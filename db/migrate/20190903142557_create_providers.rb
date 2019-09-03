class CreateProviders < ActiveRecord::Migration[5.2]
  def change
    create_table :providers do |t|
      t.string :code
      t.boolean :accredited_body

      t.timestamps
    end
  end
end
