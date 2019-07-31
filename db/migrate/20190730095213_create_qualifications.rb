class CreateQualifications < ActiveRecord::Migration[5.2]
  def change
    create_table :qualifications do |t|
      t.string :type_of_qualification
      t.string :subject
      t.string :institution
      t.string :grade
      t.integer :year

      t.timestamps
    end
  end
end
