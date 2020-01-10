class AddStatusToReferences < ActiveRecord::Migration[6.0]
  def up
    add_column :references, :feedback_status, :string, null: false, default: 'not_requested_yet'
    add_index :references, :feedback_status

    execute 'UPDATE "references" SET feedback_status = \'feedback_requested\' WHERE application_form_id IN (SELECT application_form_id FROM application_choices WHERE status != \'unsubmitted\')'
    execute 'UPDATE "references" SET feedback_status = \'feedback_provided\' WHERE feedback IS NOT NULL'
  end

  def down
    remove_column :references, :feedback_status
  end
end
