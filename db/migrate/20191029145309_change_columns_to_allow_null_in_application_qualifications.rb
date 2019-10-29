class ChangeColumnsToAllowNullInApplicationQualifications < ActiveRecord::Migration[6.0]
  def change
    change_column_null :application_qualifications, :qualification_type, true
    change_column_null :application_qualifications, :subject, true
    change_column_null :application_qualifications, :grade, true
    change_column_null :application_qualifications, :predicted_grade, true
    change_column_null :application_qualifications, :award_year, true
  end
end
