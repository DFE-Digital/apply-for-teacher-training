require 'rails_helper'

RSpec.describe 'Entering their work history' do
  include CandidateHelper

  scenario 'Candidate submits their work history when they have none' do
    given_i_am_signed_in_with_one_login

    when_i_visit_the_restructured_work_history_flow
    then_i_see_the_start_page

    when_i_choose_i_do_not_have_any_work_history
    and_i_provide_my_reason_for_not_having_worked
    then_i_see_the_work_history_review_page

    and_i_see_my_explanation

    when_i_click_on_change
    and_i_change_the_explanation
    then_i_see_my_updated_explanation

    when_i_mark_this_section_as_completed
    and_i_click_on_continue
    then_i_see_the_form
    and_that_the_section_is_completed
  end

  def when_i_visit_the_restructured_work_history_flow
    visit candidate_interface_restructured_work_history_path
  end

  def then_i_see_the_start_page
    expect(page).to have_current_path candidate_interface_restructured_work_history_path
  end

  def when_i_choose_i_do_not_have_any_work_history
    choose t('application_form.restructured_work_history.can_not_complete.label')
    click_link_or_button t('continue')
  end

  def and_i_provide_my_reason_for_not_having_worked
    fill_in 'Tell us why you have been out of the workplace', with: 'I was not working'
    click_link_or_button t('continue')
  end

  def then_i_see_the_work_history_review_page
    expect(page).to have_current_path candidate_interface_restructured_work_history_review_path
  end

  def and_i_see_my_explanation
    expect(page).to have_content('I was not working')
  end

  def when_i_click_on_change
    click_change_link('explanation')
  end

  def and_i_change_the_explanation
    fill_in 'Tell us why you have been out of the workplace', with: 'I was not working due to childcare'
    click_link_or_button t('continue')
  end

  def then_i_see_my_updated_explanation
    expect(page).to have_content('I was not working due to childcare')
  end

  def when_i_mark_this_section_as_completed
    choose t('application_form.completed_radio')
  end

  def and_i_click_on_continue
    click_link_or_button t('continue')
  end

  def then_i_see_the_form
    expect(page).to have_content(t('page_titles.application_form'))
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#work-history-badge-id', text: 'Completed')
  end
end
