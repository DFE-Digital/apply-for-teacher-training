class ValidateCheckConstraintForNotesUserIdNotNull < ActiveRecord::Migration[6.1]
  def up
    safety_assured do
      execute 'ALTER TABLE "notes" VALIDATE CONSTRAINT "notes_user_id_null"'
      execute 'ALTER TABLE "notes" ALTER COLUMN user_id SET NOT NULL'
      execute 'ALTER TABLE "notes" DROP CONSTRAINT "notes_user_id_null"'
    end
  end
end
