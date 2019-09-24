class RenameCourseIdToCourseChoiceIdOnCandidateApplications < ActiveRecord::Migration[5.2]
  def change
    rename_column :candidate_applications, :course_id, :course_choice_id
  end
end
