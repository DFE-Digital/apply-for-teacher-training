class AddStateToCandidateApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :candidate_applications, :state, :string
  end
end
