class CreateCandidates < ActiveRecord::Migration[5.2]
  def change
    create_table :candidates do |t|
      t.string :email_address, null: false, unique: true

      t.timestamps
    end

    add_index :candidates, :email_address, unique: true
  end
end
