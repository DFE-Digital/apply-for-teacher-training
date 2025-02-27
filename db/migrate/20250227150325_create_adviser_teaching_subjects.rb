class CreateAdviserTeachingSubjects < ActiveRecord::Migration[8.0]
  def change
    create_table :adviser_teaching_subjects do |t|
      t.string :title, null: false
      t.string :external_identifier, null: false
      t.string :level, null: false

      t.timestamps
    end
  end
end
