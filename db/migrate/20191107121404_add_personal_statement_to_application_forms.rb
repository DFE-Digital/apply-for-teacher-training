class AddPersonalStatementToApplicationForms < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :becoming_a_teacher, :text
    add_column :application_forms, :subject_knowledge, :text
    add_column :application_forms, :interview_preferences, :text
  end
end
