class ChangeQualificationsHesaCodesToStrings < ActiveRecord::Migration[6.0]
  def change
    change_column :application_qualifications, :qualification_type_hesa_code, :string
    change_column :application_qualifications, :subject_hesa_code, :string
    change_column :application_qualifications, :institution_hesa_code, :string
    change_column :application_qualifications, :grade_hesa_code, :string
  end
end
