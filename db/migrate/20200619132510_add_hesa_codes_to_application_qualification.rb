class AddHesaCodesToApplicationQualification < ActiveRecord::Migration[6.0]
  def change
    add_column :application_qualifications, :qualification_type_hesa_code, :bigint
    add_column :application_qualifications, :subject_hesa_code, :bigint
    add_column :application_qualifications, :institution_hesa_code, :bigint
    add_column :application_qualifications, :grade_hesa_code, :bigint

    add_index :application_qualifications, :qualification_type_hesa_code, name: 'qualifications_by_type_hesa_code'
    add_index :application_qualifications, :subject_hesa_code, name: 'qualifications_by_subject_hesa_code'
    add_index :application_qualifications, :institution_hesa_code, name: 'qualifications_by_institution_hesa_code'
    add_index :application_qualifications, :grade_hesa_code, name: 'qualifications_by_grade_hesa_code'
  end
end
