class AddCandidatesSubmissionBlockedColumn < ActiveRecord::Migration[6.1]
  def change
    add_column :candidates, :submission_blocked, :boolean, null: false, default: false
  end
end
