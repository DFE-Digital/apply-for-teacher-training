class AddCoursesRecruitmentCycleYear < ActiveRecord::Migration[6.0]
  def change
    add_column :courses, :recruitment_cycle_year, :integer
    Course.update_all recruitment_cycle_year: 2020
    change_column :courses, :recruitment_cycle_year, :integer, null: false
  end
end
