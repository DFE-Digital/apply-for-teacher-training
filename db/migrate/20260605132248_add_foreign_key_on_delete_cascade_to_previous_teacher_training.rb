class AddForeignKeyOnDeleteCascadeToPreviousTeacherTraining < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :possible_previous_teacher_trainings, :candidates
    add_foreign_key :possible_previous_teacher_trainings, :candidates, on_delete: :cascade, validate: false
  end
end
