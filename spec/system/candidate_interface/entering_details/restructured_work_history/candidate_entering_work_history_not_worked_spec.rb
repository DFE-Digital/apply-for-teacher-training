require 'rails_helper'

RSpec.feature 'Entering their work history' do
  include CandidateHelper

  scenario 'Candidate submits their work history when they have none' do
    FeatureFlag.activate(:restructured_work_history)

    given_i_am_signed_in

    when_i_try_and_visit_the_old_work_history_flow
    then_i_should_see_the_start_page

    when_i_choose_i_do_not_have_any_work_history
    and_i_provide_my_reason_for_not_having_worked
    then_i_should_see_the_work_history_review_page

    and_i_should_see_my_explanation

    when_i_click_on_change
    and_i_change_the_explanation
    then_i_should_see_my_updated_explanation

    when_i_mark_this_section_as_completed
    and_i_click_on_continue
    then_i_should_see_the_form
    and_that_the_section_is_completed
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_try_and_visit_the_old_work_history_flow
    visit candidate_interface_work_history_length_path
  end

  def then_i_should_see_the_start_page
    expect(page).to have_current_path candidate_interface_restructured_work_history_path
  end

  def when_i_choose_i_do_not_have_any_work_history
    choose t('application_form.work_history.missing.label')
    click_button t('continue')
  end

  def and_i_provide_my_reason_for_not_having_worked
    fill_in 'Tell us why you’ve been out of the workplace', with: 'I was not working'
    click_button t('continue')
  end

  def then_i_should_see_the_work_history_review_page
    expect(page).to have_current_path candidate_interface_restructured_work_history_review_path
  end

  def and_i_should_see_my_explanation
    expect(page).to have_content('I was not working')
  end

  def when_i_click_on_change
    click_change_link('explanation')
  end

  def and_i_change_the_explanation
    fill_in 'Tell us why you’ve been out of the workplace', with: 'I was not working due to childcare'
    click_button t('continue')
  end

  def then_i_should_see_my_updated_explanation
    expect(page).to have_content('I was not working due to childcare')
  end

  def when_i_mark_this_section_as_completed
    check t('application_form.work_history.review.completed_checkbox')
  end

  def and_i_click_on_continue
    click_button t('save_and_continue')
  end

  def then_i_should_see_the_form
    expect(page).to have_content(t('page_titles.application_form'))
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#work-history-badge-id', text: 'Completed')
  end
end
