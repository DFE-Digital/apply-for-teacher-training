require 'rails_helper'

RSpec.describe 'Monthly statistics page' do
  before do
    TestSuiteTimeMachine.travel_permanently_to(2023, 9, 29)
    create(
      :monthly_statistics_report,
      :v1,
      month: '2023-09',
      generation_date: Time.zone.local(2023, 9, 29),
      publication_date: Time.zone.local(2023, 9, 29),
    )
  end

  context 'with monthly statistics redirect enabled' do
    before do
      FeatureFlag.activate(:monthly_statistics_redirected)
    end

    scenario 'User can download a CSV from the monthly statistics page' do
      given_i_visit_the_monthly_statistics_page
      then_i_am_redirected_to_the_temporarily_unavailable_page
    end
  end

  context 'with monthly statistics redirect disabled' do
    before do
      FeatureFlag.deactivate(:monthly_statistics_redirected)
    end

    scenario 'User can download a CSV from the monthly statistics page' do
      given_i_visit_the_monthly_statistics_page
      and_i_see_the_monthly_statistics
      when_i_click_a_link
      then_a_csv_downloads
    end
  end

  def given_i_visit_the_monthly_statistics_page
    visit '/publications/monthly-statistics'
  end

  def then_i_am_redirected_to_the_temporarily_unavailable_page
    expect(page).to have_current_path('/publications/monthly-statistics/temporarily-unavailable')
  end

  def and_i_see_the_monthly_statistics
    expect(page).to have_content "Initial teacher training applications for courses starting in the #{current_timetable.academic_year_range_name} academic year"
  end

  def when_i_click_a_link
    click_link_or_button 'Applications by status (CSV)'
  end

  def then_a_csv_downloads
    expect(page).to(have_text('Status,First application,Apply again,Total'))
  end
end
