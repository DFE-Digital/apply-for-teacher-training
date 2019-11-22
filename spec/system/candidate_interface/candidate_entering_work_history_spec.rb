require 'rails_helper'

RSpec.feature 'Entering their work history' do
  include CandidateHelper

  scenario 'Candidate submits their work history' do
    given_i_am_signed_in
    and_i_visit_the_site

    when_i_click_on_work_history
    then_i_should_see_a_list_of_work_lengths

    when_i_omit_choosing_from_the_list_of_work_lengths
    then_i_should_see_work_history_length_validation_errors

    when_i_choose_more_than_5_years
    then_i_should_see_the_job_form

    when_i_fill_in_the_job_form
    then_i_should_see_my_completed_job

    when_i_click_on_delete_entry
    and_i_confirm
    then_i_should_be_asked_for_an_explanation

    when_i_click_on_add_job
    and_i_fill_in_the_job_form
    then_i_should_see_my_completed_job

    when_i_click_on_add_another_job
    and_i_fill_in_the_job_form_with_another_job_with_a_break
    then_i_should_see_my_second_job
    and_i_should_be_asked_to_explain_the_break_in_my_work_history

    when_i_click_to_enter_break_explanation
    then_i_see_the_work_history_break_form

    when_i_fill_in_the_work_history_break_form
    then_i_see_my_explanation_for_breaks_in_my_work_history

    when_i_click_on_change
    and_i_change_the_job_title_to_be_blank
    then_i_should_see_validation_errors

    when_i_change_the_job_title
    then_i_should_see_my_updated_job

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

  def then_i_should_see_a_list_of_work_lengths
    expect(page).to have_content(t('application_form.work_history.more_than_5.label'))
  end

  def when_i_omit_choosing_from_the_list_of_work_lengths
    click_button 'Continue'
  end

  def then_i_should_see_work_history_length_validation_errors
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/work_history_form.attributes.work_history.blank')
  end

  def when_i_choose_more_than_5_years
    choose t('application_form.work_history.more_than_5.label')
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

  def then_i_should_see_my_completed_job
    expect(page).to have_content('Chief Terraforming Officer')
  end

  def when_i_click_on_delete_entry
    click_link t('application_form.work_history.delete_entry')
  end

  def and_i_confirm
    click_button t('application_form.work_history.sure_delete_entry')
  end

  def then_i_should_be_asked_for_an_explanation
    expect(page).to have_content('Explanation of why you’ve been out of the workplace')
  end

  def when_i_click_on_add_job
    click_link t('application_form.work_history.add_job')
  end

  def when_i_click_on_add_another_job
    click_link t('application_form.work_history.add_another_job')
  end

  def and_i_fill_in_the_job_form
    when_i_fill_in_the_job_form
  end

  def and_i_fill_in_the_job_form_with_another_job_with_a_break
    scope = 'application_form.work_history'
    fill_in t('role.label', scope: scope), with: 'Chief of Xenomorph Procurement and Research'
    fill_in t('organisation.label', scope: scope), with: 'Weyland-Yutani'

    choose 'Full-time'

    within('[data-qa="start-date"]') do
      fill_in 'Month', with: '2'
      fill_in 'Year', with: '2019'
    end

    fill_in t('details.label', scope: scope), with: 'Gimme Xenomorphs.'

    choose 'No'

    click_button t('application_form.work_history.complete_form_button')
  end

  def then_i_should_see_my_second_job
    expect(page).to have_content('Chief of Xenomorph Procurement and Research')
  end

  def and_i_should_be_asked_to_explain_the_break_in_my_work_history
    expect(page).to have_content(t('application_form.work_history.break.label'))
  end

  def when_i_click_to_enter_break_explanation
    click_link t('application_form.work_history.break.enter_label')
  end

  def then_i_see_the_work_history_break_form
    expect(page).to have_content(t('page_titles.work_history_breaks'))
  end

  def when_i_fill_in_the_work_history_break_form
    fill_in t('application_form.work_history.break.label'), with: 'WE WERE ON A BREAK!'

    click_button t('application_form.work_history.break.button')
  end

  def then_i_see_my_explanation_for_breaks_in_my_work_history
    expect(page).to have_content('WE WERE ON A BREAK!')
  end

  def when_i_click_on_change
    first('.govuk-summary-list__actions').click_link 'Change'
  end

  def and_i_change_the_job_title_to_be_blank
    fill_in t('application_form.work_history.role.label'), with: ''
    click_button t('application_form.work_history.complete_form_button')
  end

  def then_i_should_see_validation_errors
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/work_experience_form.attributes.role.blank')
  end

  def when_i_change_the_job_title
    fill_in t('application_form.work_history.role.label'), with: 'Chief Executive Officer'
    click_button t('application_form.work_history.complete_form_button')
  end

  def then_i_should_see_my_updated_job
    expect(page).to have_content('Chief Executive Officer')
  end

  def when_i_mark_this_section_as_completed
    check t('application_form.work_history.review.completed_checkbox')
  end

  def and_i_click_on_continue
    click_button t('application_form.work_history.review.button')
  end

  def then_i_should_see_the_form
    expect(page).to have_content(t('page_titles.application_form'))
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#work-history-badge-id', text: 'Completed')
  end
end
