require 'rails_helper'

RSpec.feature 'Entering their work history' do
  include CandidateHelper

  scenario 'Candidate submits their work history as full time education' do
    FeatureFlag.activate(:restructured_work_history)

    given_i_am_signed_in
    and_i_visit_the_site

    when_i_click_on_work_history
    then_i_should_see_the_start_page

    when_i_choose_that_i_have_been_in_full_time_education
    then_i_should_see_the_work_history_review_page

    and_i_can_see_i_have_selected_i_was_in_full_time_education

    when_i_mark_this_section_as_completed
    and_i_click_on_continue
    then_i_should_see_the_form
    and_that_the_section_is_completed
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

  def then_i_should_see_the_start_page
    expect(page).to have_current_path candidate_interface_restructured_work_history_path
  end

  def when_i_choose_that_i_have_been_in_full_time_education
    choose t('application_form.work_history.full_time_education.label')
    click_button 'Continue'
  end

  def then_i_should_see_the_work_history_review_page
    expect(page).to have_current_path candidate_interface_restructured_work_history_review_path
  end

  def and_i_can_see_i_have_selected_i_was_in_full_time_education
    expect(page).to have_content t('application_form.work_history.full_time_education.label')
  end

  def when_i_mark_this_section_as_completed
    choose t('application_form.completed_radio')
  end

  def and_i_click_on_continue
    click_button t('continue')
  end

  def then_i_should_see_the_form
    expect(page).to have_content(t('page_titles.application_form'))
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#work-history-badge-id', text: 'Completed')
  end
end
