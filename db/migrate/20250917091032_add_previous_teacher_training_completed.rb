class AddPreviousTeacherTrainingCompleted < ActiveRecord::Migration[8.0]
  def change
    add_column(:application_forms, :previous_teacher_training_completed, :boolean)
  end
end
