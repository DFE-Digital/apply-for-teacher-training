class AddRejectedByDefaultAtToCandidateApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :candidate_applications, :rejected_by_default_at, :datetime
  end
end
