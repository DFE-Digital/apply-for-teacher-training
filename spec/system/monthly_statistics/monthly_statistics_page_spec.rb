require 'rails_helper'

RSpec.feature 'Monthly statistics page' do
  before do
    allow(MonthlyStatisticsTimetable).to receive(:generate_monthly_statistics?).and_return true
    FeatureFlag.activate('publish_monthly_statistics')
    create_application_choices
    create_monthly_stats_report
    visit_monthly_statistics_page
  end

  scenario 'User views monthly statistics page' do
    then_i_can_see_the_monthly_statistics
  end

  scenario 'User can download applicants by status (CSV)' do
    click_link 'Applicants by status (CSV)'
    expect(page).to(have_text('Status,First application,Apply again,Total'))
  end

  scenario 'User can download applications by status (CSV)' do
    click_link 'Applications by status (CSV)'
    expect(page).to(have_text('Status,First application,Apply again,Total'))
  end

  scenario 'User can download applicants by age group (CSV)' do
    click_link 'Applicants by age group (CSV)'
    expect(page).to(have_text('Age group,Recruited,Conditions'))
  end

  scenario 'User can download applicants by sex (CSV)' do
    click_link 'Applicants by sex (CSV)'
    expect(page).to(have_text('Sex,Recruited,Conditions pending,Received an offer'))
  end

  scenario 'User can download applicants by area (CSV)' do
    click_link 'Applicants by area (CSV)'
    expect(page).to(have_text('Area,Recruited,Conditions pending,Received an offer'))
  end

  scenario 'User can download applications by course age group (CSV)' do
    click_link 'Applications by course age group (CSV)'
    expect(page).to(have_text('Age group,Recruited,Conditions pending,Received an offer'))
  end

  scenario 'User can download applications by course type (CSV)' do
    click_link 'Applications by course type (CSV)'
    expect(page).to(have_text('Course type,Recruited,Conditions pending,Received an offer'))
  end

  scenario 'User can download applications by primary specialist subject (CSV)' do
    click_link 'Applications by primary specialist subject (CSV)'
    expect(page).to(have_text('Subject,Recruited,Conditions pending,Received an offer'))
  end

  scenario 'User can download applications by secondary subject (CSV)' do
    click_link 'Applications by secondary subject (CSV)'
    expect(page).to(have_text('Subject,Recruited,Conditions pending,Received an offer'))
  end

  scenario 'User can download applications by provider area (CSV)' do
    click_link 'Applications by provider area (CSV)'
    expect(page).to(have_text('Area,Recruited,Conditions pending,Received an offer'))
  end

  scenario 'User can download applicants by status, age group, sex, area (CSV)' do
    click_link 'Applicants by status, age group, sex, area (CSV)'
    expect(page).to(have_text('Sex,Area,Age group,Status,Total'))
  end

  scenario 'User can download applications by course type, age group, subject, provider area (CSV)' do
    click_link 'Applications by course type, age group, subject, provider area (CSV)'
    expect(page).to(have_text('Course type,Age group,Subject,Provider area,Total'))
  end

  def visit_monthly_statistics_page
    visit '/publications/monthly-statistics'
  end

  def then_i_can_see_the_monthly_statistics
    expect(page).to have_content "Initial teacher training applications for courses starting in the #{RecruitmentCycle.cycle_name(CycleTimetable.next_year)} academic year"
  end

  def create_application_choices
    create(:application_choice, :with_completed_application_form, :with_rejection, course_option: create(:course_option, course: create(:course, level: 'primary', subjects: [create(:subject, name: 'Primary')])))
    create(:application_choice, :with_completed_application_form, :with_offer, course_option: create(:course_option, course: create(:course, level: 'secondary', subjects: [create(:subject, name: 'English')])))
    create(:application_choice, :with_completed_application_form, :with_offer, course_option: create(:course_option, course: create(:course, level: 'further_education', subjects: [create(:subject, name: 'Further education')])))
  end

  def create_monthly_stats_report
    GenerateMonthlyStatistics.new.perform
  end
end
