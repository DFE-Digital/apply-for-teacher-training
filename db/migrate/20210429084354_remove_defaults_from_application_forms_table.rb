class RemoveDefaultsFromApplicationFormsTable < ActiveRecord::Migration[6.1]
  def change
    change_column_default :application_forms, :work_history_completed, from: false, to: nil
    change_column_default :application_forms, :degrees_completed, from: false, to: nil
    change_column_default :application_forms, :other_qualifications_completed, from: false, to: nil
    change_column_default :application_forms, :course_choices_completed, from: false, to: nil
    change_column_default :application_forms, :volunteering_completed, from: false, to: nil
    change_column_default :application_forms, :personal_details_completed, from: false, to: nil
    change_column_default :application_forms, :contact_details_completed, from: false, to: nil
    change_column_default :application_forms, :english_gcse_completed, from: false, to: nil
    change_column_default :application_forms, :maths_gcse_completed, from: false, to: nil
    change_column_default :application_forms, :science_gcse_completed, from: false, to: nil
    change_column_default :application_forms, :training_with_a_disability_completed, from: false, to: nil
    change_column_default :application_forms, :becoming_a_teacher_completed, from: false, to: nil
    change_column_default :application_forms, :subject_knowledge_completed, from: false, to: nil
    change_column_default :application_forms, :efl_completed, from: false, to: nil
  end
end
