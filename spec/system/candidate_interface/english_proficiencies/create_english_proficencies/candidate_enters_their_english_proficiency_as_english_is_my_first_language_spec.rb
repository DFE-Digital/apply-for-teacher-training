require 'rails_helper'

RSpec.describe 'Candidate enters their english proficiency as English is my first language',
               feature_flag: '2027_application_form_has_many_english_proficiencies' do
  include CandidateHelper

  scenario do
    given_i_am_signed_in_with_one_login
    and_english_is_not_my_first_language
    and_visit_my_details
    when_i_click_on_english_as_a_foreign_language
    then_i_see_the_proving_your_level_of_english_page

    when_i_click_on_continue
    then_i_see_the_proving_your_level_of_english_page
    and_i_see_validation_errors_for_not_selecting_a_level_of_english

    when_i_select_english_is_my_first_language
    and_i_click_on_continue
    then_i_see_the_review_page
    and_i_see_that_english_is_my_first_language

    when_i_select_yes_i_have_completed_this_section
    and_i_click_on_continue
  end

private

  def and_english_is_not_my_first_language
    create(:application_form, :international_address, first_nationality: 'American', candidate: current_candidate)
  end

  def and_visit_my_details
    visit candidate_interface_details_path
  end

  def when_i_click_on_english_as_a_foreign_language
    click_on 'English as a foreign language'
  end

  def then_i_see_the_proving_your_level_of_english_page
    expect(page).to have_current_path candidate_interface_english_proficiencies_start_path
    expect(page).to have_element(:span, text: 'English as a foreign language assessment', class: 'govuk-caption-xl')
    expect(page).to have_element(:h1, text: 'Proving your level of English', class: 'govuk-fieldset__heading')

    expect(page).to have_field('English is my first language', type: 'checkbox')
    expect(page).to have_field('My degree was taught in English', type: 'checkbox')
    expect(page).to have_field('I have an English as a foreign language (EFL) assessment', type: 'checkbox')
    expect(page).to have_field('None of these', type: 'checkbox')
  end

  def when_i_select_english_is_my_first_language
    check 'English is my first language'
  end

  def and_i_click_on_continue
    click_on 'Continue'
  end
  alias_method :when_i_click_on_continue, :and_i_click_on_continue

  def then_i_see_the_review_page
    expect(page).to have_current_path candidate_interface_english_proficiencies_review_path
    expect(page).to have_element(:h1, text: 'Check your English as a foreign language assessment', class: 'govuk-heading-xl')
  end

  def and_i_see_that_english_is_my_first_language
    within('.govuk-summary-card') do
      expect(page).to have_element(:h2, text: 'English as a foreign language assessment', class: 'govuk-summary-card__title')
      expect(page).to have_element(:dt, text: 'Proving your level of English', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: 'English is my first language', class: 'govuk-summary-list__value')
    end
  end

  def when_i_select_yes_i_have_completed_this_section
    choose 'Yes, I have completed this section'
  end

  def then_i_see_the_english_as_a_foreign_language_assessment_section_completed
    expect(page).to have_element(:div, text: 'English as a foreign language assessment Completed', class: 'app-task-list__content')
  end

  def and_i_see_validation_errors_for_not_selecting_a_level_of_english
    expect(page).to have_element(
      :div,
      text: 'Select a way of proving your level of English, or select ‘None of these’',
      class: 'govuk-error-summary__body',
    )
  end
end
