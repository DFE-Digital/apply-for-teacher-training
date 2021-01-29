class RemoveNullConstraintsFromApplicationExperiences < ActiveRecord::Migration[6.0]
  def change
    change_column_null :application_experiences, :details, true
    change_column_null :application_experiences, :working_with_children, true
  end
end
