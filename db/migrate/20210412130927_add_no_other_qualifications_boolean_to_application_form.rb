class AddNoOtherQualificationsBooleanToApplicationForm < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :no_other_qualifications, :boolean, default: false
  end
end
