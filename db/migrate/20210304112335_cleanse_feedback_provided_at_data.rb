class CleanseFeedbackProvidedAtData < ActiveRecord::Migration[6.0]
  def up
    CandidateInterface::BackfillDuplicateBooleanAndPopulateFeedbackProvidedAt.call
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
