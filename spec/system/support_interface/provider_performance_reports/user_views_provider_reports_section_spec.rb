require 'rails_helper'

RSpec.describe 'User views sections when reports have been generated' do
  include DfESignInHelpers

  scenario 'before reports are available to providers (ie, before report season), reports generated' do
    given_it_is_before_report_season
    and_national_and_provider_reports_have_been_generated
    sign_in_as_support_user
    when_i_navigate_to_the_providers_report_page_in_support
    then_i_see_the_report_data
    and_i_see_the_text_that_providers_do_not_yet_see_the_report
  end

  scenario 'before reports are available to providers (ie, before report season), reports not generated' do
    given_it_is_before_report_season
    and_a_provider_exists
    sign_in_as_support_user
    when_i_navigate_to_the_providers_report_page_in_support
    then_i_see_the_explanation_about_when_reports_are_available
  end

  scenario 'when reports are available to provider (ie, during report season) reports generated' do
    given_it_is_during_report_season
    and_national_and_provider_reports_have_been_generated
    and_a_provider_exists
    sign_in_as_support_user
    when_i_navigate_to_the_providers_report_page_in_support
    and_i_do_not_see_the_text_that_providers_do_not_yet_see_the_report
  end

  scenario 'when reports are available to provider (ie, during report season) reports not generated' do
    given_it_is_during_report_season
    and_a_provider_exists
    sign_in_as_support_user
    when_i_navigate_to_the_providers_report_page_in_support
    then_i_see_not_available_text
  end

  scenario 'when I try to visit the report page without signing in' do
    given_it_is_during_report_season
    and_national_and_provider_reports_have_been_generated
    when_i_visit_the_report_page
    then_i_see_a_prompt_to_sign_in
  end

private

  def given_it_is_before_report_season
    report_season_starts = RecruitmentPerformanceReportTimetable.first_publication_date
    TestSuiteTimeMachine.travel_permanently_to(report_season_starts - 1.day)
  end

  def given_it_is_during_report_season
    report_season_starts = RecruitmentPerformanceReportTimetable.first_publication_date
    TestSuiteTimeMachine.travel_permanently_to(report_season_starts + 1.day)
  end

  def and_a_provider_exists
    @provider = create(:provider)
  end

  def and_national_and_provider_reports_have_been_generated
    and_a_provider_exists
    create(
      :national_recruitment_performance_report,
      recruitment_cycle_year: current_year,
      cycle_week: RecruitmentCycleTimetable.current_cycle_week,
      generation_date: DateTime.now,
      publication_date: DateTime.now,
    )
    create(
      :provider_recruitment_performance_report,
      provider: @provider,
      recruitment_cycle_year: current_year,
      cycle_week: RecruitmentCycleTimetable.current_cycle_week,
      generation_date: DateTime.now,
      publication_date: DateTime.now,
    )
  end

  def when_i_navigate_to_the_providers_report_page_in_support
    visit support_interface_path
    click_on 'Providers'
    click_on @provider.name_and_code
    click_on 'Recruitment performance weekly report'
  end

  def then_i_see_the_report_data
    expect(page).to have_content('1. About this data')
    expect(page).to have_content('The recruitment cycle does not start on the same date each year. Where a table compares data from last cycle to this cycle, the data will not be for the same dates, but it will be for the same number of days.')
  end

  def and_i_see_the_text_that_providers_do_not_yet_see_the_report
    date = RecruitmentPerformanceReportTimetable.first_publication_date.to_datetime.to_fs(:govuk_date)
    expect(page).to have_text("These reports are not available to providers until #{date}")
  end

  def and_i_do_not_see_the_text_that_providers_do_not_yet_see_the_report
    date = RecruitmentPerformanceReportTimetable.first_publication_date.to_datetime.to_fs(:govuk_date)
    expect(page).to have_no_text("These reports are not available to providers until #{date}")
  end

  def when_i_visit_the_report_page
    visit support_interface_provider_recruitment_performance_report_path(provider_id: @provider.id)
  end

  def then_i_see_a_prompt_to_sign_in
    expect(page).to have_content 'You must sign in to use the support console'
  end

  def then_i_see_no_data_text_and_available_in_future_date
    expect(page).to have_content 'The reports for the 2025 to 2026 recruitment cycle are not available until 12 January 2026.'
  end

  def then_i_see_not_available_text
    expect(page).to have_text 'This report is not ready to view.'
  end

  def then_i_see_the_explanation_about_when_reports_are_available
    date = RecruitmentPerformanceReportTimetable.first_publication_date.to_datetime.to_fs(:govuk_date)
    "The reports for the #{current_timetable.cycle_range_name} recruitment cycle are not available until #{date}."
  end
end
