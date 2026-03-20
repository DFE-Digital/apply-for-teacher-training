require 'rails_helper'

RSpec.describe 'Candidate enters their english proficiency as has IELTS qualification',
               feature_flag: '2027_application_form_has_many_english_proficiencies' do
  include CandidateHelper

  scenario do
    given_i_am_signed_in_with_one_login
    and_english_is_not_my_first_language
    and_visit_my_details
    when_i_click_on_english_as_a_foreign_language
    then_i_see_the_proving_your_level_of_english_page

    when_i_select_i_have_an_efl_assessment
    and_i_click_on_continue
    then_i_see_the_efl_assessment_type_page

    when_i_click_on_back
    then_i_see_the_proving_your_level_of_english_edit_page
    and_i_see_i_have_an_efl_assessment_selected

    when_i_click_on_continue
    then_i_see_the_efl_assessment_type_page

    when_i_click_on_continue
    then_i_see_the_efl_assessment_type_page
    and_i_see_validation_errors_for_selecting_a_type_of_assessment

    when_i_select_ielts
    and_i_click_on_continue
    then_i_see_the_ielts_results_page

    when_i_click_on_back
    then_i_see_the_efl_assessment_type_page
    and_i_see_ielts_selected

    when_i_click_on_continue
    then_i_see_the_ielts_results_page

    when_i_click_on_save_and_continue
    then_i_see_the_ielts_results_page
    and_i_see_validation_errors_for_not_entering_my_assessment_results

    when_i_fill_in_the_ielts_results_form_with_invalid_inputs
    and_i_click_on_save_and_continue
    then_i_see_the_ielts_results_page
    and_i_see_validation_errors_for_entering_invalid_inputs

    when_i_fill_in_the_ielts_results_form
    and_i_click_on_save_and_continue
    then_i_see_the_review_page
    and_i_see_that_my_level_of_english_is_i_have_an_efl_assessment

    when_i_select_yes_i_have_completed_this_section
    and_i_click_on_continue
  end

private

  def and_english_is_not_my_first_language
    @application_form = create(:application_form, :international_address, first_nationality: 'American', candidate: current_candidate)
  end

  def and_visit_my_details
    visit candidate_interface_details_path
  end

  def when_i_click_on_english_as_a_foreign_language
    click_on 'English as a foreign language'
  end

  def then_i_see_the_proving_your_level_of_english_page
    expect(page).to have_current_path candidate_interface_english_proficiencies_start_path
    and_i_see_the_proving_your_level_of_english_form
  end

  def then_i_see_the_proving_your_level_of_english_edit_page
    english_proficiency = @application_form.english_proficiencies.last
    expect(page).to have_current_path candidate_interface_english_proficiencies_edit_start_path(english_proficiency.id)
    and_i_see_the_proving_your_level_of_english_form
  end

  def and_i_see_the_proving_your_level_of_english_form
    expect(page).to have_element(:span, text: 'English as a foreign language assessment', class: 'govuk-caption-xl')
    expect(page).to have_element(:h1, text: 'Proving your level of English', class: 'govuk-fieldset__heading')

    expect(page).to have_field('English is my first language', type: 'checkbox')
    expect(page).to have_field('My degree was taught in English', type: 'checkbox')
    expect(page).to have_field('I have an English as a foreign language (EFL) assessment', type: 'checkbox')
    expect(page).to have_field('None of these', type: 'checkbox')
  end

  def when_i_select_i_have_an_efl_assessment
    check 'I have an English as a foreign language (EFL) assessment'
  end

  def and_i_click_on_continue
    click_on 'Continue'
  end
  alias_method :when_i_click_on_continue, :and_i_click_on_continue

  def then_i_see_the_efl_assessment_type_page
    english_proficiency = @application_form.english_proficiencies.last
    expect(page).to have_current_path(candidate_interface_english_proficiencies_type_path(english_proficiency), ignore_query: true)
    expect(page).to have_element(:span, text: 'English as a foreign language assessment', class: 'govuk-caption-xl')
    expect(page).to have_element(:h1, text: 'What English language assessment did you do?', class: 'govuk-fieldset__heading')

    expect(page).to have_field('International English Language Testing System (IELTS)', type: 'radio')
    expect(page).to have_field('Test of English as a Foreign Language (TOEFL)', type: 'radio')
    expect(page).to have_field('Other', type: 'radio')
  end

  def when_i_click_on_back
    click_on 'Back'
  end

  def and_i_see_i_have_an_efl_assessment_selected
    expect(page).to have_checked_field('I have an English as a foreign language (EFL) assessment', type: 'checkbox')
  end

  def when_i_select_ielts
    choose 'International English Language Testing System (IELTS)'
  end

  def then_i_see_the_ielts_results_page
    english_proficiency = @application_form.english_proficiencies.last
    expect(page).to have_current_path candidate_interface_english_proficiencies_ielts_path(english_proficiency)
    expect(page).to have_element(:span, text: 'English as a foreign language assessment', class: 'govuk-caption-xl')
    expect(page).to have_element(:h1, text: 'Your IELTS result', class: 'govuk-heading-xl')
    expect(page).to have_field('Test report form (TRF) number', type: 'text')
    expect(page).to have_field('Overall band score', type: 'text')
    expect(page).to have_field('When did you complete the assessment?', type: 'text')
  end

  def and_i_see_ielts_selected
    expect(page).to have_checked_field('International English Language Testing System (IELTS)')
  end

  def when_i_fill_in_the_ielts_results_form
    fill_in 'Test report form (TRF) number', with: 'ABCD1234'
    fill_in 'Overall band score', with: '8'
    fill_in 'When did you complete the assessment?', with: '2020'
  end

  def and_i_click_on_save_and_continue
    click_on 'Save and continue'
  end
  alias_method :when_i_click_on_save_and_continue, :and_i_click_on_save_and_continue

  def then_i_see_the_review_page
    expect(page).to have_current_path candidate_interface_english_proficiencies_review_path
    expect(page).to have_element(:h1, text: 'Check your English as a foreign language assessment', class: 'govuk-heading-xl')
  end

  def and_i_see_that_my_level_of_english_is_i_have_an_efl_assessment
    within('.govuk-summary-card') do
      expect(page).to have_element(:h2, text: 'English as a foreign language assessment', class: 'govuk-summary-card__title')
      expect(page).to have_element(:dt, text: 'Proving your level of English', class: 'govuk-summary-list__key')
      expect(page).to have_element(
        :dd,
        text: 'I have an English as a foreign language (EFL) assessment',
        class: 'govuk-summary-list__value',
      )
      expect(page).to have_element(:dt, text: 'Type of assessment', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: 'IELTS', class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Test report form (TRF) number', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: 'ABCD1234', class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Overall band score', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: '8.0', class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Year completed', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: '2020', class: 'govuk-summary-list__value')
    end
  end

  def when_i_select_yes_i_have_completed_this_section
    choose 'Yes, I have completed this section'
  end

  def then_i_see_the_english_as_a_foreign_language_assessment_section_completed
    expect(page).to have_element(
      :div,
      text: 'English as a foreign language assessment Completed',
      class: 'app-task-list__content',
    )
  end

  def and_i_see_validation_errors_for_selecting_a_type_of_assessment
    expect(page).to have_element(
      :div,
      text: 'Select your type of assessment',
      class: 'govuk-error-summary__body',
    )
  end

  def and_i_see_validation_errors_for_not_entering_my_assessment_results
    expect(page).to have_element(
      :div,
      text: 'Enter your TRF number',
      class: 'govuk-error-summary__body',
    )
    expect(page).to have_element(
      :div,
      text: 'Enter your overall band score',
      class: 'govuk-error-summary__body',
    )
    expect(page).to have_element(
      :div,
      text: 'Enter year the assessment was done',
      class: 'govuk-error-summary__body',
    )
  end

  def when_i_fill_in_the_ielts_results_form_with_invalid_inputs
    fill_in 'Test report form (TRF) number', with: 'a' * 256
    fill_in 'Overall band score', with: '8'
    fill_in 'When did you complete the assessment?', with: '1979'
  end

  def and_i_see_validation_errors_for_entering_invalid_inputs
    expect(page).to have_element(
      :div,
      text: 'Trf number must be 255 characters or fewer',
      class: 'govuk-error-summary__body',
    )
    expect(page).to have_element(
      :div,
      text: 'Assessment year cannot be before 1980',
      class: 'govuk-error-summary__body',
    )
  end
end
