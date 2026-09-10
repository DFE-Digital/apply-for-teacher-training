class AddCourseIdsToCandidatePoolApplications < ActiveRecord::Migration[8.1]
  def change
    add_column :candidate_pool_applications, :course_ids, :bigint, array: true, null: false, default: []
  end
end
