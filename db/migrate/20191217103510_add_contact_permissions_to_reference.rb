class AddContactPermissionsToReference < ActiveRecord::Migration[6.0]
  def change
    add_column :references, :rejected_reference_request, :boolean
    add_column :references, :allows_user_research, :boolean, null: false, default: false
  end
end
