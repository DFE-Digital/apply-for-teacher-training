class UpdateGradesToStructuredGrades < ActiveRecord::Migration[6.0]
  def change
    rename_column :application_qualifications, :grades, :structured_grades
  end
end
