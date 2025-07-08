class AddCourseTypeToCandidatePreferences < ActiveRecord::Migration[8.0]
  def change
    add_column :candidate_preferences, :funding_type, :string
  end
end
