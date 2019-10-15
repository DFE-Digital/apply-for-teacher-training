class CreateCourses < ActiveRecord::Migration[6.0]
  def change
    create_table :courses do |t|
      t.references :provider, null: false, foreign_key: true
      t.string :name
      t.string :code

      t.timestamps
    end

    add_index :courses, :code, unique: true
  end
end
