class AddAgeRangesToCandidatePoolApplications < ActiveRecord::Migration[8.1]
  def change
    add_column :candidate_pool_applications, :age_ranges, :string, array: true, null: false, default: []
  end
end
