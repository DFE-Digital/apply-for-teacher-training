class AddColumnsToApplicationExperiences < ActiveRecord::Migration[6.0]
  def change
    add_column :application_experiences, :relevant_skills, :boolean
    add_column :application_experiences, :currently_working, :boolean
    add_column :application_experiences, :start_date_unknown, :boolean
    add_column :application_experiences, :end_date_unknown, :boolean
  end
end
