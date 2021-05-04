class RemoveNullConstraintsFromApplicationFormsTable < ActiveRecord::Migration[6.1]
  def change
    change_column_null :application_forms, :work_history_completed, true
    change_column_null :application_forms, :degrees_completed, true
    change_column_null :application_forms, :other_qualifications_completed, true
    change_column_null :application_forms, :course_choices_completed, true
    change_column_null :application_forms, :volunteering_completed, true
    change_column_null :application_forms, :personal_details_completed, true
    change_column_null :application_forms, :contact_details_completed, true
    change_column_null :application_forms, :english_gcse_completed, true
    change_column_null :application_forms, :maths_gcse_completed, true
    change_column_null :application_forms, :science_gcse_completed, true
    change_column_null :application_forms, :training_with_a_disability_completed, true
    change_column_null :application_forms, :becoming_a_teacher_completed, true
    change_column_null :application_forms, :subject_knowledge_completed, true
    change_column_null :application_forms, :efl_completed, true
  end
end
