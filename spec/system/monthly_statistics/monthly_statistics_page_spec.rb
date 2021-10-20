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
    create(:application_choice, :with_completed_application_form, :with_rejection, course_option: create(:course_option, course: create(:course, level: 'primary', subjects: [create(:subject, name: 'Primary')])))
    create(:application_choice, :with_completed_application_form, :with_offer, course_option: create(:course_option, course: create(:course, level: 'secondary', subjects: [create(:subject, name: 'English')])))
    create(:application_choice, :with_completed_application_form, :with_offer, course_option: create(:course_option, course: create(:course, level: 'further_education')))
  end

  def create_monthly_stats_report
    UpdateMonthlyStatisticsReport.new.perform
  end
end
