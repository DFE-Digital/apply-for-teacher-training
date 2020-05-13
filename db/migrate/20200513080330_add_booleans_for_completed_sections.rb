class AddBooleansForCompletedSections < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :personal_details_completed, :boolean, default: false
    add_column :application_forms, :contact_details_completed, :boolean, default: false
    add_column :application_forms, :english_gcse_completed, :boolean, default: false
    add_column :application_forms, :maths_gcse_completed, :boolean, default: false
    add_column :application_forms, :additional_support_completed, :boolean, default: false
    add_column :application_forms, :safeguarding_issues_completed, :boolean, default: false
    add_column :application_forms, :personal_statement_completed, :boolean, default: false
    add_column :application_forms, :subject_knowledge_completed, :boolean, default: false
    add_column :application_forms, :interview_needs_completed, :boolean, default: false
    add_column :application_forms, :references_completed, :boolean, default: false
  end
end
