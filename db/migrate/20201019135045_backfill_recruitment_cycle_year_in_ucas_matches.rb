class BackfillRecruitmentCycleYearInUCASMatches < ActiveRecord::Migration[6.0]
  def change
    start_of_2021_cycle = Date.new(2020, 10, 13)

    ucas_matches_in_2020_cycle = UCASMatch.where('created_at < ?', start_of_2021_cycle)
    ucas_matches_in_2020_cycle.update_all(recruitment_cycle_year: 2020)

    ucas_matches_in_2021_cycle = UCASMatch.where('created_at >= ?', start_of_2021_cycle)
    ucas_matches_in_2021_cycle.update_all(recruitment_cycle_year: 2021)

    change_column_null :ucas_matches, :recruitment_cycle_year, false
  end
end
