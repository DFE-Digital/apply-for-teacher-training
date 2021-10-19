class DropUCASMatches < ActiveRecord::Migration[6.1]
  def change
    drop_table :ucas_matches do
      t.bigint 'candidate_id'
      t.json 'matching_data'
      t.datetime 'created_at'
      t.datetime 'updated_at'
      t.integer 'recruitment_cycle_year'
      t.datetime 'candidate_last_contacted_at'
      t.string 'action_taken'
    end
  end
end
