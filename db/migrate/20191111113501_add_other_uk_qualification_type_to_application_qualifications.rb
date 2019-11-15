class AddOtherUkQualificationTypeToApplicationQualifications < ActiveRecord::Migration[6.0]
  def change
    add_column :application_qualifications, :other_uk_qualification_type, :string, limit: 100
  end
end
