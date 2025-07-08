class AddCourseTypeToCandidatePoolApplication < ActiveRecord::Migration[8.0]
  def change
    add_column :candidate_pool_applications, :course_funding_type_fee, :boolean
  end
end
