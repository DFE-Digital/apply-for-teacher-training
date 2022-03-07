class AddDegreeSubjectUuidToApplicationQualifications < ActiveRecord::Migration[6.1]
  def change
    add_column :application_qualifications, :degree_subject_uuid, :uuid
  end
end
