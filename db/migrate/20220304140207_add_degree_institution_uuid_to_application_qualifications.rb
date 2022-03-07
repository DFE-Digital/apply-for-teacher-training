class AddDegreeInstitutionUuidToApplicationQualifications < ActiveRecord::Migration[6.1]
  def change
    add_column :application_qualifications, :degree_institution_uuid, :uuid
  end
end
