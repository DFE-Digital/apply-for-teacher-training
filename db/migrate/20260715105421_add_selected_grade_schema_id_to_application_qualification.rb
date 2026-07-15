class AddSelectedGradeSchemaIdToApplicationQualification < ActiveRecord::Migration[8.1]
  def change
    add_column :application_qualifications, :selected_grade_schema_id, :string
  end
end
