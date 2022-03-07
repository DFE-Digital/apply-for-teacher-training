class AddDegreeGradeUuidToApplicationQualifications < ActiveRecord::Migration[6.1]
  def change
    add_column :application_qualifications, :degree_grade_uuid, :uuid
  end
end
