class AddRequestAtToReferences < ActiveRecord::Migration[6.0]
  def up
    add_column :references, :requested_at, :datetime
    execute 'UPDATE "references" SET requested_at = (SELECT submitted_at FROM application_forms WHERE "references".application_form_id = application_forms.id)'
  end

  def down
    remove_column :references, :requested_at, :datetime
  end
end
