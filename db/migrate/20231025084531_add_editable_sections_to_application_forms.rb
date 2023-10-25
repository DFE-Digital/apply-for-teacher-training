class AddEditableSectionsToApplicationForms < ActiveRecord::Migration[7.0]
  def change
    add_column :application_forms, :editable_sections, :jsonb
  end
end
