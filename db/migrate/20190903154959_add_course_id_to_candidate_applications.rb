class AddCourseIdToCandidateApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :candidate_applications, :course_id, :integer
  end
end
