class AddAcceptedTsAndCsAtToCandidates < ActiveRecord::Migration[6.0]
  def change
    add_column :candidates, :accepted_ts_and_cs_at, :datetime
  end
end
