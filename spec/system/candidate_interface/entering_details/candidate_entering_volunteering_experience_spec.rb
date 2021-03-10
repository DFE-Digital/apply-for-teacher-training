require 'rails_helper'

RSpec.feature 'Entering volunteering experience' do
  include CandidateHelper

  scenario 'Candidate adds volunteering experience' do
    FeatureFlag.activate('restructured_work_history')

    given_i_am_signed_in
    and_i_visit_the_site

    when_i_click_on_unpaid_experience
    then_i_should_see_the_start_page

    when_i_choose_yes_experience
    and_i_submit_the_volunteering_experience_form
    then_i_see_the_add_volunteering_role_form

    when_i_fill_in_the_job_form_with_incorrect_date_fields
    then_i_should_see_date_validation_errors
    and_i_should_see_the_incorrect_date_values

    when_i_fill_in_the_job_form_with_valid_details
    then_i_should_see_the_volunteering_review_page
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_unpaid_experience
    click_link t('page_titles.volunteering.short')
  end

  def then_i_should_see_the_start_page
    expect(page).to have_content(t('application_form.volunteering.experience.label'))
  end

  def when_i_choose_yes_experience
    choose 'Yes'
  end

  def and_i_submit_the_volunteering_experience_form
    click_button t('save_and_continue')
  end

  def then_i_see_the_add_volunteering_role_form
    expect(page).to have_content(t('page_titles.add_volunteering_role'))
  end

  def when_i_fill_in_the_job_form_with_incorrect_date_fields
    within('[data-qa="start-date"]') do
      fill_in 'Month', with: '33'
      fill_in 'Year', with: '1999'
    end

    click_button t('save_and_continue')
  end

  def then_i_should_see_date_validation_errors
    expect(page).to have_content t('errors.messages.invalid_date', article: 'a', attribute: 'start date')
  end

  def and_i_should_see_the_incorrect_date_values
    within('[data-qa="start-date"]') do
      expect(find_field('Month').value).to eq('33')
    end
  end

  def when_i_fill_in_the_job_form_with_valid_details
    scope = 'application_form.volunteering'
    fill_in t('organisation.label', scope: scope), with: 'National Trust'
    fill_in t('role.label', scope: scope), with: 'Tour guide'

    within('[data-qa="working-with-children"]') do
      choose 'Yes'
    end

    within('[data-qa="start-date"]') do
      fill_in 'Month', with: '5'
      fill_in 'Year', with: '2014'
    end

    within('[data-qa="currently-working"]') do
      choose 'No'
    end

    within('[data-qa="end-date"]') do
      fill_in 'Month', with: '1'
      fill_in 'Year', with: '2019'
    end

    fill_in t('application_form.volunteering.details.label'), with: 'I volunteered.'
    click_button t('save_and_continue')
  end

  def then_i_should_see_the_volunteering_review_page
    expect(page).to have_current_path candidate_interface_review_volunteering_path
  end
end
