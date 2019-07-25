class CreateDegrees < ActiveRecord::Migration[5.2]
  def change
    create_table :degrees do |t|
      t.string :type_of_degree
      t.string :subject
      t.string :institution
      t.string :class_of_degree
      t.integer :year

      t.timestamps
    end
  end
end
