require 'rails_helper'

RSpec.feature 'Monthly statistics page', mid_cycle: false do
  include StatisticsTestHelper

  before do
    TestSuiteTimeMachine.travel_permanently_to(2021, 12, 29)
    allow(MonthlyStatisticsTimetable).to receive(:generate_monthly_statistics?).and_return(true)
    generate_statistics_test_data
    create_monthly_stats_report
  end

  scenario 'User can download a CSV from the monthly statistics page' do
    given_i_visit_the_monthly_statistics_page
    then_i_should_be_redirected_to_the_temporarily_unavailable_page
  end

  def create_monthly_stats_report
    GenerateMonthlyStatistics.new.perform
  end

  def given_i_visit_the_monthly_statistics_page
    visit '/publications/monthly-statistics'
  end

  def then_i_should_be_redirected_to_the_temporarily_unavailable_page
    expect(page).to have_current_path('/publications/monthly-statistics/temporarily-unavailable')
  end
end
