class DropApplicationFormsRecruitmentCycleYearDefault < ActiveRecord::Migration[6.0]
  def change
    change_column :application_forms, :recruitment_cycle_year, :integer, default: nil
  end
end
