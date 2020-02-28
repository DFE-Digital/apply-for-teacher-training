require 'rails_helper'

RSpec.feature 'Editing their work history' do
  include CandidateHelper

  scenario 'Candidate attempts to submit without adding a job or giving an explanation' do
    given_i_am_signed_in
    and_i_visit_the_site

    when_i_click_on_work_history
    and_i_choose_more_than_5_years
    and_i_fill_in_the_job_form
    and_i_click_on_delete_entry
    and_i_confirm

    when_i_mark_this_section_as_completed
    and_i_click_on_continue
    then_i_should_be_told_i_need_to_give_additional_information
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

  def then_i_should_see_a_list_of_work_lengths
    expect(page).to have_content(t('application_form.work_history.more_than_5.label'))
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

    click_button t('application_form.work_history.complete_form_button')
  end

  def and_i_click_on_delete_entry
    click_link t('application_form.work_history.delete_entry')
  end

  def and_i_confirm
    click_button t('application_form.work_history.sure_delete_entry')
  end

  def when_i_mark_this_section_as_completed
    check t('application_form.work_history.review.completed_checkbox')
  end

  def and_i_click_on_continue
    click_button t('application_form.work_history.review.button')
  end

  def then_i_should_be_told_i_need_to_give_additional_information
    expect(page).to have_content 'Please complete your work history or tell us why you’ve been out of the workplace'
  end
end
