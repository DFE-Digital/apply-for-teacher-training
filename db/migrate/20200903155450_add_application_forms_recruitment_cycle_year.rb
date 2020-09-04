class AddApplicationFormsRecruitmentCycleYear < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :recruitment_cycle_year, :integer, null: false, default: 2020
  end
end
