require 'rails_helper'

RSpec.feature 'Monthly statistics page' do
  before do
    create_application_choices
    create_monthly_stats_report
  end

  scenario 'User visits monthly statistics page' do
    when_i_visit_the_monthly_statistics_page
    then_i_can_see_the_monthly_statistics
  end

  def when_i_visit_the_monthly_statistics_page
    visit '/monthly-statistics'
  end

  def then_i_can_see_the_monthly_statistics
    expect(page).to have_content 'Applicants for initial teacher training courses'
  end

  def create_application_choices
    create_application_choice(status: :with_rejection, course_level: 'primary')
    create_application_choice(status: :with_offer, course_level: 'secondary')
    create_application_choice(status: :with_offer, course_level: 'further_education')
  end

  def create_application_choice(status:, course_level:)
    create(:application_choice, status, course_option: create(:course_option, course: create(:course, level: course_level)))
  end

  def create_monthly_stats_report
    UpdateMonthlyStatisticsReport.new.perform
  end
end
