class CreateCandidateApplications < ActiveRecord::Migration[5.2]
  def change
    create_table :candidate_applications, &:timestamps
  end
end
