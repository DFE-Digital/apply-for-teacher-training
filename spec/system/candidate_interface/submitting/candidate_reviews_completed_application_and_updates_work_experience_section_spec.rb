require 'rails_helper'

RSpec.feature 'Candidate is redirected correctly' do
  include CandidateHelper

  scenario 'Candidate reviews completed application and updates restructured work experience section' do
    given_i_am_signed_in
    when_i_have_completed_my_application
    and_i_review_my_application
    then_i_should_see_all_sections_are_complete

    # update job
    when_i_click_change_job
    then_i_should_see_the_job_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_job
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_job

    # section complete
    when_i_mark_the_work_experience_section_as_incomplete
    and_i_review_my_application
    and_i_click_link_complete_your_work_history

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_work_history_completed
    then_i_should_be_redirected_to_the_application_review_page

    # delete job
    when_i_click_delete_job
    then_i_should_see_the_delete_job_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_delete_job
    then_i_should_be_redirected_to_the_application_review_page

    # update work break
    when_i_click_change_work_break
    then_i_should_see_the_work_break_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_work_break
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_work_break

    # delete work break
    when_i_click_delete_work_break
    then_i_should_see_the_delete_work_break_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_delete_work_break
    then_i_should_be_redirected_to_the_application_review_page
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_have_completed_my_application
    candidate_completes_application_form(with_restructured_work_history: true)
  end

  def when_i_mark_the_work_experience_section_as_incomplete
    visit candidate_interface_application_form_path
    click_link 'Work history'
    choose t('application_form.incomplete_radio')
    click_button t('continue')
  end

  def and_i_review_my_application
    and_i_visit_the_application_form_page
    when_i_click_on_check_your_answers
  end

  def and_i_click_link_complete_your_work_history
    click_link 'Complete your work history'
  end

  def then_i_should_see_all_sections_are_complete
    application_form_sections.each do |section|
      expect(page).not_to have_selector "[data-qa='incomplete-#{section}']"
    end
  end

  def and_i_visit_the_application_form_page
    visit candidate_interface_application_form_path
  end

  def then_i_should_see_the_work_break_form
    expect(page).to have_content('Please tell us what you were doing over this period')
  end

  def then_i_should_see_the_delete_job_form
    expect(page).to have_content('Are you sure you want to delete this job?')
  end

  def when_i_click_on_check_your_answers
    click_link 'Check and submit your application'
  end

  def then_i_should_be_redirected_to_the_application_review_page
    expect(page).to have_current_path(candidate_interface_application_review_path)
  end

  def when_i_click_back
    click_link 'Back'
  end

  def when_i_click_change_job
    click_link 'Change job'
  end

  def when_i_click_delete_job
    click_link 'Delete job'
  end

  def when_i_click_change_work_break
    click_link 'Change entry for break'
  end

  def when_i_click_delete_work_break
    click_link 'Delete entry for break'
  end

  def when_i_update_job
    when_i_click_change_job

    within('[data-qa="start-date"]') do
      fill_in 'Month', with: '3'
    end

    click_button t('save_and_continue')
  end

  def when_i_update_work_break
    when_i_click_change_work_break
    fill_in 'Enter reasons for break in work history', with: 'The Nostromo blew up'
    click_button t('continue')
  end

  def when_i_update_work_history_completed
    and_i_click_link_complete_your_work_history

    choose t('application_form.completed_radio')
    click_button t('continue')
  end

  def when_i_delete_job
    when_i_click_delete_job
    click_button t('application_form.restructured_work_history.delete_job.confirm')
  end

  def when_i_delete_work_break
    when_i_click_delete_work_break

    click_button 'Yes I’m sure - delete this entry'
  end

  def then_i_should_see_the_job_form
    expect(page).to have_content('Edit job')
  end

  def then_i_should_see_the_delete_work_break_form
    expect(page).to have_content('Are you sure you want to delete this entry?')
  end

  def and_i_should_see_my_updated_job
    within('[data-qa="job-date"]') do
      expect(page).to have_content('Mar 2014')
    end
  end

  def and_i_should_see_my_updated_work_break
    within('[data-qa="work-break-reason"]') do
      expect(page).to have_content('The Nostromo blew up')
    end
  end
end
