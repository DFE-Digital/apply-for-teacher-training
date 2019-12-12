class AddCoursesRecruitmentCycleYear < ActiveRecord::Migration[6.0]
  def change
    add_column :courses, :recruitment_cycle_year, :integer
    change_column_null :courses, :recruitment_cycle_year, false, 2020
  end
end
