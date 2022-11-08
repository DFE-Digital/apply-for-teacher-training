class DropReferencesEmailAddressUniqueIndex < ActiveRecord::Migration[7.0]
  def change
    remove_index :references, column: [:application_form_id, :email_address], name: 'index_references_on_application_form_id_and_email_address'
  end
end
