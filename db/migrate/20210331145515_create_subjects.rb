class CreateSubjects < ActiveRecord::Migration[6.0]
  def change
    create_table :subjects do |t|
      t.string :name
      t.string :code

      t.timestamps
    end
    add_index :subjects, :code, unique: true
  end
end
