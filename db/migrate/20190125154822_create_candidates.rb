class CreateCandidates < ActiveRecord::Migration[5.2]
  def change
    create_table :candidates, id: :uuid do |t|
      t.string :title, index: true
      t.string :first_name, index: true
      t.string :surname, index: true
      t.date :date_of_birth
      t.integer :gender, default: 0, index: true

      t.timestamps
    end
  end
end
