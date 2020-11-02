class AddSubjectAreaToApplicationQualifications < ActiveRecord::Migration[6.0]
  def change
    add_column :application_qualifications, :subject_area, :string
  end
end
