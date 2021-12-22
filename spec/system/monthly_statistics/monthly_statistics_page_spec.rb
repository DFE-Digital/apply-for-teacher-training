require 'rails_helper'

RSpec.feature 'Monthly statistics page' do
  include MonthlyStatisticsTestHelper
  before do
    allow(MonthlyStatisticsTimetable).to receive(:generate_monthly_statistics?).and_return true
    FeatureFlag.activate('publish_monthly_statistics')
    generate_monthly_statistics_test_data
    create_monthly_stats_report
  end

  scenario 'User can download a CSV from the monthly statistics page' do
    given_i_visit_the_monthly_statistics_page
    and_i_see_the_monthly_statistics
    when_i_click_a_link
    then_a_csv_downloads
  end

  def create_monthly_stats_report
    GenerateMonthlyStatistics.new.perform
  end

  def given_i_visit_the_monthly_statistics_page
    visit '/publications/monthly-statistics'
  end

  def and_i_see_the_monthly_statistics
    expect(page).to have_content "Initial teacher training applications for courses starting in the #{RecruitmentCycle.cycle_name(CycleTimetable.next_year)} academic year"
  end

  def when_i_click_a_link
    click_link 'Applications by status (CSV)'
  end

  def then_a_csv_downloads
    expect(page).to(have_text('Status,First application,Apply again,Total'))
  end
end
