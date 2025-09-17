class AddPrecisionNilToPreviousTeacherTraining < ActiveRecord::Migration[8.0]
  def up
    safety_assured do
      change_column :application_forms, :previous_teacher_training_completed_at, :datetime, precision: nil
    end
  end

  def down
    safety_assured do
      change_column :application_forms, :previous_teacher_training_completed_at, :datetime
    end
  end
end
