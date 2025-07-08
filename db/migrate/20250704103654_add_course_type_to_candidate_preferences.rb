class AddCourseTypeToCandidatePreferences < ActiveRecord::Migration[8.0]
  def change
    add_column :candidate_preferences, :course_type, :string
  end
end
