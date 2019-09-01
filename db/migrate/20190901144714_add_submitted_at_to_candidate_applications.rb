class AddSubmittedAtToCandidateApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :candidate_applications, :submitted_at, :datetime
  end
end
