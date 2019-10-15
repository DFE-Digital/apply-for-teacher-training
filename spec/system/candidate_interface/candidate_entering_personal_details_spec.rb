require 'rails_helper'

RSpec.feature 'Entering their personal details' do
  scenario 'Candidate submits their personal details' do
    given_i_am_signed_in
    and_i_visit_the_site

    when_i_click_on_personal_details
    and_i_fill_in_some_details_but_omit_some_required_details
    and_i_submit_the_form
    then_i_should_see_validation_errors

    when_i_fill_in_the_rest_of_my_details
    and_i_submit_the_form
    then_i_can_check_my_answers

    when_i_click_to_change_my_answer
    and_i_fill_in_a_different_answer
    and_i_submit_the_form
    then_i_can_check_my_revised_answers

    when_i_submit_my_details
    then_i_should_see_the_form
    and_that_the_section_is_completed

    when_i_click_on_personal_details
    then_i_can_check_my_revised_answers
  end

  def given_i_am_signed_in
    candidate = create(:candidate)
    login_as(candidate)
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_personal_details
    click_link t('page_titles.personal_details')
  end

  def and_i_fill_in_some_details_but_omit_some_required_details
    scope = 'application_form.personal_details'
    fill_in t('first_name.label', scope: scope), with: 'Lando'
    fill_in t('last_name.label', scope: scope), with: 'Calrissian'
  end

  def then_i_should_see_validation_errors
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/personal_details_form.attributes.date_of_birth.invalid')
  end

  def when_i_fill_in_the_rest_of_my_details
    scope = 'application_form.personal_details'
    fill_in 'Day', with: '6'
    fill_in 'Month', with: '4'
    fill_in 'Year', with: '1937'

    select('British', from: t('nationality.label', scope: scope))
    find('details').click
    within('details') do
      select('American', from: t('second_nationality.label', scope: scope))
    end

    choose 'Yes'
    fill_in t('english_main_language.yes_label', scope: scope), with: "I'm great at Galactic Basic so English is a piece of cake", match: :prefer_exact
  end

  def and_i_submit_the_form
    click_button t('application_form.personal_details.complete_form_button')
  end

  def then_i_can_check_my_answers
    expect(page).to have_content 'Name'
    expect(page).to have_content 'Lando Calrissian'
  end

  def when_i_click_to_change_my_answer
    first('.govuk-summary-list__actions').click_link 'Change'
  end

  def and_i_fill_in_a_different_answer
    scope = 'application_form.personal_details'
    fill_in t('first_name.label', scope: scope), with: 'Billy Dee'
    fill_in t('last_name.label', scope: scope), with: 'Williams'
  end

  def then_i_can_check_my_revised_answers
    expect(page).to have_content 'Name'
    expect(page).to have_content 'Billy Dee Williams'
  end

  def when_i_submit_my_details
    click_link 'Continue'
  end

  def then_i_should_see_the_form
    expect(page).to have_content(t('page_titles.personal_details'))
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#personal-details-completed', text: 'Completed')
  end
end
