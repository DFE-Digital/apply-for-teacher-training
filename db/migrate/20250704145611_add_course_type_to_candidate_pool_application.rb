class AddCourseTypeToCandidatePoolApplication < ActiveRecord::Migration[8.0]
  def change
    add_column :candidate_pool_applications, :fee_funding_type, :boolean
  end
end
