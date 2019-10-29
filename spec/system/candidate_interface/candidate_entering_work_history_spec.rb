require 'rails_helper'

RSpec.feature 'Entering their work history' do
  include CandidateHelper

  scenario 'Candidate submits their work history' do
    given_i_am_not_signed_in
    and_i_visit_the_work_history_page
    then_i_should_see_the_homepage

    given_i_am_signed_in
    and_i_visit_the_site

    when_i_click_on_work_history
    then_i_should_see_a_list_of_work_lengths

    when_i_choose_more_than_5_years
    then_i_should_see_the_job_form

    when_i_fill_in_the_job_form
    then_i_should_see_my_completed_job
  end

  def given_i_am_not_signed_in; end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_visit_the_work_history_page
    visit candidate_interface_work_history_length_path
  end

  def then_i_should_see_the_homepage
    expect(page).to have_current_path(candidate_interface_start_path)
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_work_history
    click_link t('page_titles.work_history')
  end

  def then_i_should_see_a_list_of_work_lengths
    expect(page).to have_content(t('application_form.work_history.more_than_5'))
  end

  def when_i_choose_more_than_5_years
    choose t('application_form.work_history.more_than_5')
    click_button 'Continue'
  end

  def then_i_should_see_the_job_form
    expect(page).to have_content(t('page_titles.add_job'))
  end

  def when_i_fill_in_the_job_form
    scope = 'application_form.work_history'
    fill_in t('role.label', scope: scope), with: 'Chief Terraforming Officer'
    fill_in t('organisation.label', scope: scope), with: 'Weyland-Yutani'

    choose 'Full-time'

    within('[data-qa="start-date"]') do
      fill_in 'Month', with: '5'
      fill_in 'Year', with: '2119'
    end

    within('[data-qa="end-date"]') do
      fill_in 'Month', with: '1'
      fill_in 'Year', with: '2129'
    end

    fill_in t('details.label', scope: scope), with: 'I gained exposure to breakthrough technologies and questionable business ethics'

    choose 'No'

    click_button t('complete_form_button', scope: scope)
  end

  def then_i_should_see_my_completed_job
    expect(page).to have_content('Chief Terraforming Officer')
  end
end
