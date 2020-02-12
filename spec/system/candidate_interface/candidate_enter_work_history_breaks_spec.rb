require 'rails_helper'

RSpec.feature 'Entering reasons for their work history breaks' do
  include CandidateHelper

  scenario 'Candidate enters a reason for a work break' do
    FeatureFlag.activate('work_breaks')

    given_i_am_signed_in
    and_i_visit_the_site

    when_i_click_on_work_history
    and_i_choose_i_have_work_for_more_than_5_years
    and_i_add_a_job_between_march_2019_to_august_2019
    and_i_add_another_job_between_november_2019_and_now
    then_i_see_a_two_months_break_between_my_first_job_and_my_second_job

    when_i_click_add_another_job_for_my_break
    then_i_should_see_the_start_and_end_date_filled_in
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_work_history
    click_link t('page_titles.work_history')
  end

  def and_i_choose_i_have_work_for_more_than_5_years
    choose t('application_form.work_history.more_than_5.label')

    click_button 'Continue'
  end

  def and_i_add_a_job_between_march_2019_to_august_2019
    scope = 'application_form.work_history'
    fill_in t('role.label', scope: scope), with: 'Microsoft Painter'
    fill_in t('organisation.label', scope: scope), with: 'Department for Education'

    choose 'Full-time'

    within('[data-qa="start-date"]') do
      fill_in 'Month', with: '3'
      fill_in 'Year', with: '2019'
    end

    within('[data-qa="end-date"]') do
      fill_in 'Month', with: '8'
      fill_in 'Year', with: '2019'
    end

    fill_in t('details.label', scope: scope), with: 'I taught others to be pros at MS Paint.'

    choose 'No'

    choose 'Yes, I want to add another job'

    click_button t('application_form.work_history.complete_form_button')
  end

  def and_i_add_another_job_between_november_2019_and_now
    scope = 'application_form.work_history'
    fill_in t('role.label', scope: scope), with: 'Junior Developer'
    fill_in t('organisation.label', scope: scope), with: 'Department for Education'

    choose 'Full-time'

    within('[data-qa="start-date"]') do
      fill_in 'Month', with: '11'
      fill_in 'Year', with: '2019'
    end

    fill_in t('details.label', scope: scope), with: 'Ship it.'

    choose 'No'

    choose 'No, I’ve completed my work history'

    click_button t('application_form.work_history.complete_form_button')
  end

  def then_i_see_a_two_months_break_between_my_first_job_and_my_second_job
    expect(page).to have_content('You have a break in your work history (2 months)')
  end

  def when_i_click_add_another_job_for_my_break
    first(:link, t('application_form.work_history.add_another_job')).click
  end

  def then_i_should_see_the_start_and_end_date_filled_in
    expect(page).to have_selector("input[value='8']")
    expect(page).to have_selector("input[value='2019']")
    expect(page).to have_selector("input[value='11']")
    expect(page).to have_selector("input[value='2019']")
  end
end
