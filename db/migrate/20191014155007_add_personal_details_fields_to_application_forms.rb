class AddPersonalDetailsFieldsToApplicationForms < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :first_nationality, :string
    add_column :application_forms, :second_nationality, :string
    add_column :application_forms, :english_main_language, :boolean
    add_column :application_forms, :english_language_details, :text
    add_column :application_forms, :other_language_details, :text
    add_column :application_forms, :date_of_birth, :date
  end
end
