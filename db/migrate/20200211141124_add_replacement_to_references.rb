class AddReplacementToReferences < ActiveRecord::Migration[6.0]
  def up
    add_column :references, :replacement, :boolean, default: false, null: false

    # We added new references manually for these:
    #
    # https://www.apply-for-teacher-training.education.gov.uk/support/applications/60
    # https://www.apply-for-teacher-training.education.gov.uk/support/applications/172
    execute 'UPDATE "references" SET replacement = true WHERE id IN (47, 62)'
  end

  def down
    remove_column :references, :replacement
  end
end
