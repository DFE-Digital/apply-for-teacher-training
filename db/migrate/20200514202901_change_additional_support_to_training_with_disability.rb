class ChangeAdditionalSupportToTrainingWithDisability < ActiveRecord::Migration[6.0]
  def change
    rename_column :application_forms, :additional_support_completed, :training_with_a_disability_completed
    rename_column :application_forms, :personal_statement_completed, :becoming_a_teacher_completed
    rename_column :application_forms, :interview_needs_completed, :interview_preferences_completed
  end
end
