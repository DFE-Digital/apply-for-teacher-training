require 'rails_helper'

RSpec.feature 'Entering their work history' do
  include CandidateHelper

  scenario 'Candidate submits their work history when they have none' do
    given_i_am_signed_in
    and_my_application_form_is_marked_as_having_used_the_existing_flow
    and_i_visit_the_site

    when_i_click_on_work_history
    when_i_choose_not_worked
    then_i_should_see_the_work_history_explanation_form

    when_i_fill_in_the_work_history_explanation_form
    then_i_should_see_my_explanation

    when_i_click_on_change
    and_i_change_the_explanation
    then_i_should_see_my_updated_explanation

    when_i_mark_this_section_as_completed
    and_i_click_on_continue
    then_i_should_see_the_form
    and_that_the_section_is_completed

    when_i_click_on_work_history
    then_i_should_see_my_explanation
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_my_application_form_is_marked_as_having_used_the_existing_flow
    current_candidate.current_application.update(feature_restructured_work_history: false)
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_work_history
    click_link t('page_titles.work_history')
  end

  def when_i_choose_not_worked
    choose t('application_form.work_history.missing.label')
    click_button t('continue')
  end

  def then_i_should_see_the_work_history_explanation_form
    expect(page).to have_content(t('page_titles.work_history_explanation'))
  end

  def when_i_fill_in_the_work_history_explanation_form
    fill_in t('application_form.work_history.explanation.label'), with: 'I was not working'
    click_button t('continue')
  end

  def then_i_should_see_my_explanation
    expect(page).to have_content('I was not working')
  end

  def when_i_click_on_change
    click_change_link('explanation')
  end

  def and_i_change_the_explanation
    fill_in t('application_form.work_history.explanation.label'), with: 'I was not working 2'
    click_button t('continue')
  end

  def then_i_should_see_my_updated_explanation
    expect(page).to have_content('I was not working 2')
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
