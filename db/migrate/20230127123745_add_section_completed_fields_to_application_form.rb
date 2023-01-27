class AddSectionCompletedFieldsToApplicationForm < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      change_table :application_forms, bulk: true do |t|
        t.datetime :becoming_a_teacher_completed_at
        t.datetime :contact_details_completed_at
        t.datetime :course_choices_completed_at
        t.datetime :degrees_completed_at
        t.datetime :efl_completed_at
        t.datetime :english_gcse_completed_at
        t.datetime :interview_preferences_completed_at
        t.datetime :maths_gcse_completed_at
        t.datetime :other_qualifications_completed_at
        t.datetime :personal_details_completed_at
        t.datetime :references_completed_at
        t.datetime :safeguarding_issues_completed_at
        t.datetime :science_gcse_completed_at
        t.datetime :subject_knowledge_completed_at
        t.datetime :training_with_a_disability_completed_at
        t.datetime :volunteering_completed_at
        t.datetime :work_history_completed_at
      end
    end
  end
end
