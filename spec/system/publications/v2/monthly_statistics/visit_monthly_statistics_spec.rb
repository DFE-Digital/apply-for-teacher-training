require 'rails_helper'

RSpec.describe 'Visit Monthly statistics V2 page', mid_cycle: false do
  before do
    TestSuiteTimeMachine.travel_permanently_to(2023, 12, 29)
    create(
      :monthly_statistics_report,
      :v2,
      month: '2023-12',
      generation_date: Time.zone.local(2023, 12, 18),
    )
  end

  scenario 'User can visit the monthly statistics page when it is enabled' do
    given_the_monthly_statistics_redirect_is_disabled
    and_i_visit_the_monthly_statistics_page
    and_i_see_the_monthly_statistics
  end

  scenario 'User is redirected on monthly statistics page when it is disabled' do
    given_the_monthly_statistics_redirect_is_enabled
    and_i_visit_the_monthly_statistics_page
    then_i_am_redirected_to_the_temporarily_unavailable_page
  end

  scenario 'User tries to view a draft report' do
    given_the_monthly_statistics_redirect_is_disabled
    and_a_draft_report_exists
    when_i_try_to_view_that_draft_report
    then_i_see_the_error_page
  end

  def and_i_visit_the_monthly_statistics_page
    visit '/publications/monthly-statistics/ITT2024'
  end

  def and_a_draft_report_exists
    publication_date = 1.month.from_now
    @draft_report = create(
      :monthly_statistics_report,
      :v2,
      publication_date:,
      month: "#{publication_date.year}-#{publication_date.month}",
    )
  end

  def when_i_try_to_view_that_draft_report
    visit "/publications/monthly-statistics/#{@draft_report.month}"
  end

  def then_i_see_the_error_page
    expect(page).to have_content 'Page not found'
  end

  def given_the_monthly_statistics_redirect_is_enabled
    FeatureFlag.activate(:monthly_statistics_redirected)
  end

  def given_the_monthly_statistics_redirect_is_disabled
    FeatureFlag.deactivate(:monthly_statistics_redirected)
  end

  def then_i_am_redirected_to_the_temporarily_unavailable_page
    expect(page).to have_current_path('/publications/monthly-statistics/temporarily-unavailable')
  end

  def and_i_see_the_monthly_statistics
    cycle_name = current_timetable.academic_year_range_name
    expect(page).to have_content "Initial teacher training applications for courses starting in the #{cycle_name} academic year"
  end
end
