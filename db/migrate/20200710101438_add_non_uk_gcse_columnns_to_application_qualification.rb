class AddNonUkGcseColumnnsToApplicationQualification < ActiveRecord::Migration[6.0]
  def change
    add_column :application_qualifications, :non_uk_qualification_type, :string
    add_column :application_qualifications, :comparable_uk_qualification, :string
  end
end
