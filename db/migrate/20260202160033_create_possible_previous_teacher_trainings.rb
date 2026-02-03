class CreatePossiblePreviousTeacherTrainings < ActiveRecord::Migration[8.0]
  def change
    create_table :possible_previous_teacher_trainings do |t|
      t.string :provider_name, null: false
      t.date :started_on, null: false
      t.date :ended_on, null: false
      t.references :candidate, null: false, foreign_key: true
      t.references :provider, null: true, foreign_key: true

      t.timestamps
    end
  end
end
