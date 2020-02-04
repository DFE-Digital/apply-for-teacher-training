class AddWorkingPatternToApplicationExperiences < ActiveRecord::Migration[6.0]
  def change
    add_column :application_experiences, :working_pattern, :string
  end
end
