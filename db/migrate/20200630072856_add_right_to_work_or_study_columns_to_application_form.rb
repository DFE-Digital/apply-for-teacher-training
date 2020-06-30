class AddRightToWorkOrStudyColumnsToApplicationForm < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :right_to_work_or_study, :string
    add_column :application_forms, :right_to_work_or_study_details, :string
    add_column :application_forms, :multiple_nationalities_details, :string
  end
end
