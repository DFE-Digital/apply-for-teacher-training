require 'rails_helper'

RSpec.feature 'Visit national recruitment cycle performance report page' do
  before { FeatureFlag.activate(:recruitment_cycle_performance_report) }

  scenario 'national report has been generated' do
    given_a_national_recruitment_performance_report_has_been_generated
    and_i_visit_the_national_recruitment_report_page
    then_i_see_the_report
  end

  scenario 'national report has not been generated' do
    given_i_visit_the_national_recruitment_report_page
    then_i_see_no_report_message
  end

private

  def given_a_national_recruitment_performance_report_has_been_generated
    create(:national_recruitment_performance_report)
  end

  def and_i_visit_the_national_recruitment_report_page
    visit publications_recruitment_performance_reports_path
  end
  alias_method :given_i_visit_the_national_recruitment_report_page, :and_i_visit_the_national_recruitment_report_page

  def then_i_see_the_report
    expect(page).to have_content('National recruitment performance weekly report 2023 to 2024')
    expect(page).to have_content('This report shows national initial teacher training (ITT) recruitment performance so far this recruitment cycle')
  end

  def then_i_see_no_report_message
    expect(page).to have_content('National recruitment performance weekly report 2023 to 2024')
    expect(page).to have_content('This report is not ready to view.')
  end
end
