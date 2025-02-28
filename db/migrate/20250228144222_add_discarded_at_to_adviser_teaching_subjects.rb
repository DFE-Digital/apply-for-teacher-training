class AddDiscardedAtToAdviserTeachingSubjects < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_column :adviser_teaching_subjects, :discarded_at, :datetime
    add_index :adviser_teaching_subjects, :discarded_at, algorithm: :concurrently
  end
end
