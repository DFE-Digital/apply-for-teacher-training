class AddRecruitmentCycleYearToUCASMatches < ActiveRecord::Migration[6.0]
  def change
    add_column :ucas_matches, :recruitment_cycle_year, :integer
  end
end
