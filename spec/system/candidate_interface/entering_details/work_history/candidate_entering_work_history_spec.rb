require 'rails_helper'

RSpec.feature 'Entering their work history' do
  include CandidateHelper

  scenario 'Candidate submits their work history' do
    FeatureFlag.deactivate(:restructured_work_history)

    given_i_am_signed_in
    and_i_visit_the_site

    when_i_click_on_work_history
    then_i_should_see_a_list_of_work_lengths
    and_my_application_form_is_marked_as_having_used_the_existing_flow

    when_i_omit_choosing_from_the_list_of_work_lengths
    then_i_should_see_work_history_length_validation_errors

    when_i_choose_complete
    then_i_should_see_the_job_form

    when_i_fill_in_the_job_form_with_incorrect_date_fields
    then_i_should_see_date_validation_errors
    and_i_should_see_the_incorrect_date_values

    when_i_fill_in_the_job_form
    then_i_should_see_my_completed_job

    when_i_click_on_delete_entry
    and_i_confirm
    then_i_should_see_a_list_of_work_lengths

    when_i_choose_complete
    and_i_fill_in_the_job_form # 5/2014 - 1/2019
    then_i_should_see_my_completed_job

    when_i_click_on_change
    then_i_should_not_be_asked_if_i_want_to_add_another_job

    when_i_change_the_job_title_to_be_blank
    then_i_should_see_validation_errors

    when_i_change_the_job_title
    then_i_should_see_my_updated_job

    when_i_click_on_continue
    then_i_see_a_section_complete_error

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
    expect(page).to have_content(t('application_form.work_history.complete.label'))
  end

  def and_my_application_form_is_marked_as_having_used_the_existing_flow
    expect(ApplicationForm.last.feature_restructured_work_history).to eq false
  end

  def when_i_omit_choosing_from_the_list_of_work_lengths
    click_button t('continue')
  end

  def then_i_should_see_work_history_length_validation_errors
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/work_history_form.attributes.work_history.blank')
  end

  def when_i_choose_complete
    choose t('application_form.work_history.complete.label')
    click_button t('continue')
  end

  def then_i_should_see_the_job_form
    expect(page).to have_content(t('page_titles.add_job'))
  end

  def when_i_fill_in_the_job_form_with_incorrect_date_fields
    within('[data-qa="start-date"]') do
      fill_in 'Month', with: '33'
      fill_in 'Year', with: '2010'
    end

    within('[data-qa="end-date"]') do
      fill_in 'Month', with: '11'
      fill_in 'Year', with: '9999'
    end

    click_button t('save_and_continue')
  end

  def then_i_should_see_date_validation_errors
    expect(page).to have_content t('errors.messages.invalid_date', article: 'a', attribute: 'start date')
    expect(page).to have_content t('errors.messages.invalid_date', article: 'an', attribute: 'end date')
  end

  def and_i_should_see_the_incorrect_date_values
    within('[data-qa="start-date"]') do
      expect(find_field('Month').value).to eq('33')
    end

    within('[data-qa="end-date"]') do
      expect(find_field('Year').value).to eq('9999')
    end
  end

  def when_i_fill_in_the_job_form
    scope = 'application_form.work_history'
    fill_in t('role.label', scope: scope), with: 'Chief Terraforming Officer'
    fill_in t('organisation.label', scope: scope), with: 'Weyland-Yutani'

    choose 'Part time'

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
    choose 'No, not at the moment'

    click_button t('save_and_continue')
  end

  def then_i_should_see_my_completed_job
    expect(page).to have_content('Chief Terraforming Officer')
    expect(page).to have_content('I had a working pattern')
  end

  def when_i_click_on_delete_entry
    click_link t('application_form.work_history.delete_entry.action')
  end

  def and_i_confirm
    click_button t('application_form.work_history.delete_entry.confirm')
  end

  def when_i_click_on_add_job
    click_link t('application_form.work_history.add.button')
  end

  def and_i_fill_in_the_job_form
    when_i_fill_in_the_job_form
  end

  def when_i_click_on_change
    click_change_link('job title')
  end

  def then_i_should_not_be_asked_if_i_want_to_add_another_job
    expect(page).not_to have_content 'Do you want to add another job?'
  end

  def when_i_change_the_job_title_to_be_blank
    fill_in t('application_form.work_history.role.label'), with: ''
    click_button t('save_and_continue')
  end

  def then_i_should_see_validation_errors
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/work_experience_form.attributes.role.blank')
  end

  def when_i_change_the_job_title
    fill_in t('application_form.work_history.role.label'), with: 'Chief Executive Officer'
    click_button t('save_and_continue')
  end

  def then_i_should_see_my_updated_job
    expect(page).to have_content('Chief Executive Officer')
  end

  def when_i_mark_this_section_as_completed
    choose t('application_form.completed_radio')
  end

  def then_i_see_a_section_complete_error
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/section_complete_form.attributes.completed.blank')
  end

  def and_i_click_on_continue
    click_button t('continue')
  end

  def when_i_click_on_continue
    and_i_click_on_continue
  end

  def then_i_should_see_the_form
    expect(page).to have_content(t('page_titles.application_form'))
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#work-history-badge-id', text: 'Completed')
  end
end
