require 'rails_helper'

RSpec.feature 'Entering their personal details' do
  include CandidateHelper

  scenario 'Candidate submits their personal details' do
    given_i_am_signed_in
    and_i_visit_the_site

    when_i_click_on_personal_information
    and_i_fill_in_some_details_but_omit_some_required_details
    and_i_submit_the_form
    then_i_should_see_validation_errors
    and_i_should_see_the_completed_fields

    when_i_fill_in_the_rest_of_my_details
    and_i_submit_the_form
    then_i_see_the_nationality_page

    when_i_input_my_nationalities
    and_i_submit_the_form
    then_i_see_the_review_page
    and_i_can_check_my_answers

    when_i_click_to_change_my_answer
    and_i_fill_in_a_different_answer
    and_i_submit_the_form
    then_i_can_check_my_revised_answers

    when_i_submit_my_details
    then_i_see_a_section_complete_error

    when_i_mark_the_section_as_completed
    and_i_submit_my_details
    then_i_should_see_the_form
    and_that_the_section_is_completed

    when_i_click_on_personal_information
    then_i_can_check_my_revised_answers
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_personal_information
    click_link t('page_titles.personal_information')
  end

  def and_i_fill_in_some_details_but_omit_some_required_details
    @scope = 'application_form.personal_details'
    fill_in t('first_name.label', scope: @scope), with: 'Lando'
    fill_in t('last_name.label', scope: @scope), with: 'Calrissian'
    fill_in 'Day', with: 'a'
    fill_in 'Month', with: '11'
    fill_in 'Year', with: '1975'
  end

  def then_i_should_see_validation_errors
    expect(page).to have_content t('errors.messages.invalid_date', article: 'a', attribute: 'date of birth')
  end

  def and_i_should_see_the_completed_fields
    expect(find_field(t('first_name.label', scope: @scope)).value).to eq('Lando')
    expect(find_field(t('last_name.label', scope: @scope)).value).to eq('Calrissian')
    expect(find_field('Month').value).to eq('11')
  end

  def when_i_fill_in_the_rest_of_my_details
    fill_in 'Day', with: '6'
    fill_in 'Month', with: '4'
    fill_in 'Year', with: '1937'
  end

  def and_i_submit_the_form
    click_button t('save_and_continue')
  end

  def then_i_see_the_nationality_page
    expect(page).to have_current_path candidate_interface_nationalities_path
  end

  def when_i_input_my_nationalities
    check 'British'
    check 'Citizen of a different country'
    within('#candidate-interface-nationalities-form-other-nationality1-field') do
      select 'American'
    end
  end

  def then_i_see_a_section_complete_error
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/section_complete_form.attributes.completed.blank')
  end

  def then_i_see_the_review_page
    expect(page).to have_current_path candidate_interface_personal_details_show_path
  end

  def and_i_can_check_my_answers
    expect(page).to have_content 'Name'
    expect(page).to have_content 'Lando Calrissian'
    expect(page).to have_content 'British and American'
  end

  def when_i_click_to_change_my_answer
    click_change_link('name')
  end

  def and_i_fill_in_a_different_answer
    fill_in t('first_name.label', scope: @scope), with: 'Billy Dee'
    fill_in t('last_name.label', scope: @scope), with: 'Williams'
  end

  def then_i_can_check_my_revised_answers
    expect(page).to have_content 'Name'
    expect(page).to have_content 'Billy Dee Williams'
  end

  def when_i_mark_the_section_as_completed
    choose t('application_form.completed_radio')
  end

  def and_i_submit_my_details
    click_button t('continue')
  end

  def when_i_submit_my_details
    and_i_submit_my_details
  end

  def then_i_should_see_the_form
    expect(page).to have_content(t('page_titles.personal_information'))
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#personal-information-badge-id', text: 'Completed')
  end
end
