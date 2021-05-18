class AddReferencesCompletedBooleanToApplicationForms < ActiveRecord::Migration[6.1]
  def change
    add_column :application_forms, :references_completed, :boolean
  end
end
