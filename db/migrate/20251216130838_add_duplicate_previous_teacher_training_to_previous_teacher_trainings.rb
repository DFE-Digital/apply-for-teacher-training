class AddDuplicatePreviousTeacherTrainingToPreviousTeacherTrainings < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_reference :previous_teacher_trainings, :duplicate_previous_teacher_training, index: { algorithm: :concurrently }
  end
end
