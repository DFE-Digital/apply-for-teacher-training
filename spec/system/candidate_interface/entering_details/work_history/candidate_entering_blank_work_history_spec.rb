require 'rails_helper'

RSpec.feature 'Entering their work history' do
  include CandidateHelper

  scenario 'Candidate submits their work history' do
    given_i_am_signed_in
    and_my_application_form_is_marked_as_having_used_the_existing_flow
    and_i_visit_the_site

    when_i_click_on_work_history
    then_i_should_see_a_list_of_work_lengths

    when_i_choose_complete
    then_i_should_see_the_job_form

    when_i_leave_all_fields_blank_and_submit
    then_i_should_be_redirected_to_work_history
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

  def then_i_should_see_a_list_of_work_lengths
    expect(page).to have_content(t('application_form.work_history.complete.label'))
  end

  def when_i_choose_complete
    choose t('application_form.work_history.complete.label')
    click_button t('continue')
  end

  def then_i_should_see_the_job_form
    expect(page).to have_content(t('page_titles.add_job'))
  end

  def when_i_leave_all_fields_blank_and_submit
    click_button t('save_and_continue')
  end

  def then_i_should_be_redirected_to_work_history
    expect(page).to have_content(t('page_titles.work_history'))
  end
end
