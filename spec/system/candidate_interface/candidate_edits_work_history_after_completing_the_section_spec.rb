require 'rails_helper'

RSpec.feature 'Candidate deletes their work history' do
  include CandidateHelper

  scenario 'Candidate tries to complete the section with no job, then edits their work history when the section is completed' do
    given_i_am_signed_in

    when_i_visit_the_application_page
    and_i_click_on_work_history
    and_i_choose_more_than_5_years
    and_i_fill_in_the_job_form
    and_i_click_on_delete_entry
    and_i_click_on_confirm

    when_i_mark_this_section_as_completed
    and_i_click_on_continue
    then_i_should_be_told_i_need_to_give_additional_information

    when_i_click_on_add_job
    and_i_fill_in_the_job_form
    and_i_mark_this_section_as_completed
    and_i_click_on_continue
    then_the_work_history_section_should_be_marked_as_complete

    when_i_click_on_work_history
    and_i_click_on_add_another_job
    and_i_fill_in_the_job_form

    when_i_visit_the_application_page
    then_the_work_history_section_should_be_marked_as_incomplete

    when_i_click_on_work_history
    and_i_mark_this_section_as_completed
    and_i_click_on_continue
    then_the_work_history_section_should_be_marked_as_complete

    when_i_click_on_work_history
    and_i_click_on_change
    and_i_change_the_job_title

    when_i_visit_the_application_page
    then_the_work_history_section_should_be_marked_as_incomplete

    when_i_click_on_work_history
    and_i_mark_this_section_as_completed
    and_i_click_on_continue
    then_the_work_history_section_should_be_marked_as_complete

    when_i_click_on_work_history
    and_i_click_on_delete_entry
    and_i_click_on_confirm

    when_i_visit_the_application_page
    then_the_work_history_section_should_be_marked_as_incomplete
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def when_i_visit_the_application_page
    visit candidate_interface_application_form_path
  end

  def and_i_click_on_work_history
    click_link t('page_titles.work_history')
  end

  def and_i_choose_more_than_5_years
    choose t('application_form.work_history.more_than_5.label')
    click_button 'Continue'
  end

  def and_i_fill_in_the_job_form
    scope = 'application_form.work_history'
    fill_in t('role.label', scope: scope), with: 'Chief Terraforming Officer'
    fill_in t('organisation.label', scope: scope), with: 'Weyland-Yutani'

    choose 'Part-time'

    fill_in 'Give details about your working pattern', with: 'I had a working pattern'

    within('[data-qa="start-date"]') do
      fill_in 'Month', with: '5'
      fill_in 'Year', with: '2014'
    end

    within('[data-qa="end-date"]') do
      fill_in 'Month', with: '1'
      fill_in 'Year', with: '2019'
    end

    fill_in t('details.label', scope: scope), with: 'I gained exposure to breakthrough technologies and questionable business ethics'

    choose 'No'
    choose 'No, I’ve completed my work history'

    click_button t('application_form.work_history.complete_form_button')
  end

  def and_i_click_on_delete_entry
    click_link t('application_form.work_history.delete_entry'), match: :first
  end

  def and_i_click_on_confirm
    click_button t('application_form.work_history.sure_delete_entry')
  end

  def when_i_mark_this_section_as_completed
    and_i_mark_this_section_as_completed
  end

  def then_the_work_history_section_should_be_marked_as_complete
    expect(page.text).to include 'Work history Completed'
  end

  def and_i_click_on_add_another_job
    click_link t('application_form.work_history.add_another_job')
  end

  def when_i_click_on_work_history
    and_i_click_on_work_history
  end

  def when_i_click_on_add_job
    click_link t('application_form.work_history.add_job')
  end

  def and_i_mark_this_section_as_completed
    check t('application_form.work_history.review.completed_checkbox')
  end

  def and_i_click_on_continue
    click_button t('application_form.work_history.review.button')
  end

  def then_i_should_be_told_i_need_to_give_additional_information
    expect(page).to have_content 'Please complete your work history or tell us why you’ve been out of the workplace'
  end

  def and_i_click_on_change
    first('.govuk-summary-list__actions').click_link 'Change'
  end

  def and_i_change_the_job_title
    fill_in t('application_form.work_history.role.label'), with: 'Chief Executive Officer'
    click_button t('application_form.work_history.complete_form_button')
  end

  def then_the_work_history_section_should_be_marked_as_incomplete
    expect(page.text).to include 'Work history Incomplete'
  end
end
