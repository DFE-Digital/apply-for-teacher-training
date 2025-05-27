class AddFilterFieldsToCandidatePoolApplications < ActiveRecord::Migration[8.0]
  def change
    add_column :candidate_pool_applications, :needs_visa, :boolean, null: false, default: false
    add_column :candidate_pool_applications, :study_mode_full_time, :boolean, null: false, default: false
    add_column :candidate_pool_applications, :study_mode_part_time, :boolean, null: false, default: false
    add_column :candidate_pool_applications, :course_type_postgraduate, :boolean, null: false, default: false
    add_column :candidate_pool_applications, :course_type_undergraduate, :boolean, null: false, default: false
    add_column :candidate_pool_applications, :subject_ids, :bigint, array: true, null: false, default: []
  end
end
