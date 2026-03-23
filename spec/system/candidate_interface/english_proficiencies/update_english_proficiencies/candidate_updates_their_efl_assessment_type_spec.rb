require 'rails_helper'

RSpec.describe 'Candidate updates their efl assessment type',
               feature_flag: '2027_application_form_has_many_english_proficiencies' do
  include CandidateHelper

  scenario do
    given_i_am_signed_in_with_one_login
    and_english_is_not_my_first_language
    and_i_have_previous_entered_my_english_proficiency
    and_visit_my_details
    when_i_click_on_english_as_a_foreign_language
    then_i_see_the_review_page
    and_i_see_that_my_level_of_english_is_i_have_an_ielts_efl_assessment

    when_i_click_on_change_type_of_assessment
    then_i_see_the_efl_assessment_type_page
    and_i_see_ielts_selected

    when_i_click_on_back
    then_i_see_the_review_page
    and_i_see_that_my_level_of_english_is_i_have_an_ielts_efl_assessment

    when_i_click_on_change_type_of_assessment
    then_i_see_the_efl_assessment_type_page
    and_i_see_ielts_selected

    when_i_select_toefl
    and_i_click_on_continue
    then_i_see_the_toefl_results_page

    when_i_click_on_back
    then_i_see_the_efl_assessment_type_page
    and_i_see_toefl_selected

    when_i_click_on_continue
    then_i_see_the_toefl_results_page

    when_i_fill_in_the_toefl_results_form
    and_i_click_on_save_and_continue
    then_i_see_the_review_page
    and_i_see_that_my_level_of_english_is_i_have_a_toefl_efl_assessment

    when_i_click_on_change_type_of_assessment
    then_i_see_the_efl_assessment_type_page
    and_i_see_toefl_selected

    when_i_select_other
    and_i_click_on_continue
    then_i_see_the_other_efl_results_page

    when_i_click_on_back
    then_i_see_the_efl_assessment_type_page
    and_i_see_other_selected

    when_i_click_on_continue
    then_i_see_the_other_efl_results_page

    when_i_fill_in_the_other_efl_results_form
    and_i_click_on_save_and_continue
    then_i_see_the_review_page
    and_i_see_that_my_level_of_english_is_i_have_another_efl_assessment

    when_i_click_on_change_type_of_assessment
    then_i_see_the_efl_assessment_type_page
    and_i_see_other_selected

    when_i_select_ielts
    and_i_click_on_continue
    then_i_see_the_ielts_results_page

    when_i_click_on_back
    then_i_see_the_efl_assessment_type_page
    and_i_see_ielts_selected

    when_i_click_on_continue
    then_i_see_the_ielts_results_page

    when_i_fill_in_the_ielts_results_form
    and_i_click_on_save_and_continue
    then_i_see_the_review_page
    and_i_see_that_my_level_of_english_is_i_have_an_ielts_efl_assessment
  end

private

  def and_english_is_not_my_first_language
    @application_form = create(
      :application_form,
      :international_address,
      first_nationality: 'American',
      candidate: current_candidate,
    )
  end

  def and_i_have_previous_entered_my_english_proficiency
    @efl_qualification = create(:ielts_qualification)
    @english_proficiency = create(
      :english_proficiency,
      application_form: @application_form,
      has_qualification: true,
      efl_qualification: @efl_qualification,
    )
  end

  def and_visit_my_details
    visit candidate_interface_details_path
  end

  def when_i_click_on_english_as_a_foreign_language
    click_on 'English as a foreign language'
  end

  def then_i_see_the_review_page
    expect(page).to have_current_path candidate_interface_english_proficiencies_review_path
    expect(page).to have_element(:h1, text: 'Check your English as a foreign language assessment', class: 'govuk-heading-xl')
  end

  def and_i_see_that_my_level_of_english_is_i_have_an_ielts_efl_assessment
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
      expect(page).to have_element(:dd, text: @efl_qualification.trf_number, class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Overall band score', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: @efl_qualification.band_score, class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Year completed', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: @efl_qualification.award_year, class: 'govuk-summary-list__value')
    end
  end

  def when_i_click_on_change_type_of_assessment
    click_on 'Change type of assessment'
  end

  def then_i_see_the_efl_assessment_type_page
    english_proficiency = @application_form.english_proficiencies.last
    expect(page).to have_current_path(candidate_interface_english_proficiencies_type_path(english_proficiency), ignore_query: true)
    expect(page).to have_element(:span, text: 'English as a foreign language assessment', class: 'govuk-caption-xl')
    expect(page).to have_element(:h1, text: 'What English language assessment did you do?', class: 'govuk-fieldset__heading')

    expect(page).to have_field('International English Language Testing System (IELTS)', type: 'radio')
    expect(page).to have_field('Test of English as a Foreign Language (TOEFL)', type: 'radio')
    expect(page).to have_field('Other', type: 'radio')
  end

  def and_i_see_ielts_selected
    expect(page).to have_checked_field('International English Language Testing System (IELTS)')
  end

  def when_i_click_on_back
    click_on 'Back'
  end

  def when_i_select_toefl
    choose 'Test of English as a Foreign Language (TOEFL)'
  end

  def when_i_click_on_continue
    click_on 'Continue'
  end
  alias_method :and_i_click_on_continue, :when_i_click_on_continue

  def then_i_see_the_toefl_results_page
    english_proficiency = @application_form.english_proficiencies.last
    expect(page).to have_current_path candidate_interface_english_proficiencies_toefl_path(english_proficiency)
    expect(page).to have_element(:span, text: 'English as a foreign language assessment', class: 'govuk-caption-xl')
    expect(page).to have_element(:h1, text: 'Your TOEFL result', class: 'govuk-heading-xl')
    expect(page).to have_field('TOEFL registration number', type: 'text')
    expect(page).to have_field('Total score', type: 'text')
    expect(page).to have_field('When did you complete the assessment?', type: 'text')
  end

  def and_i_see_toefl_selected
    expect(page).to have_checked_field('Test of English as a Foreign Language (TOEFL)')
  end

  def when_i_fill_in_the_toefl_results_form
    fill_in 'TOEFL registration number', with: 'ABCD1234'
    fill_in 'Total score', with: '89'
    fill_in 'When did you complete the assessment?', with: '2020'
  end

  def and_i_click_on_save_and_continue
    click_on 'Save and continue'
  end

  def and_i_see_that_my_level_of_english_is_i_have_a_toefl_efl_assessment
    within('.govuk-summary-card') do
      expect(page).to have_element(:h2, text: 'English as a foreign language assessment', class: 'govuk-summary-card__title')
      expect(page).to have_element(:dt, text: 'Proving your level of English', class: 'govuk-summary-list__key')
      expect(page).to have_element(
        :dd,
        text: 'I have an English as a foreign language (EFL) assessment',
        class: 'govuk-summary-list__value',
      )
      expect(page).to have_element(:dt, text: 'Type of assessment', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: 'TOEFL', class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'TOEFL registration number', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: 'ABCD1234', class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Year completed', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: '2020', class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Total score', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: '89', class: 'govuk-summary-list__value')
    end
  end

  def when_i_select_other
    choose 'Other'
  end

  def then_i_see_the_other_efl_results_page
    english_proficiency = @application_form.english_proficiencies.last
    expect(page).to have_current_path candidate_interface_english_proficiencies_other_efl_qualification_path(english_proficiency)
    expect(page).to have_element(:span, text: 'English as a foreign language assessment', class: 'govuk-caption-xl')
    expect(page).to have_element(:h1, text: 'Your English language assessment result', class: 'govuk-heading-xl')
    expect(page).to have_field('Assessment name', type: 'text')
    expect(page).to have_field('Score or grade', type: 'text')
    expect(page).to have_field('When did you complete the assessment?', type: 'text')
  end

  def and_i_see_other_selected
    expect(page).to have_checked_field('Other')
  end

  def when_i_fill_in_the_other_efl_results_form
    fill_in 'Assessment name', with: 'EFL Assessment ABC'
    fill_in 'Score or grade', with: 'A+'
    fill_in 'When did you complete the assessment?', with: '2020'
  end

  def and_i_see_that_my_level_of_english_is_i_have_another_efl_assessment
    within('.govuk-summary-card') do
      expect(page).to have_element(:h2, text: 'English as a foreign language assessment', class: 'govuk-summary-card__title')
      expect(page).to have_element(:dt, text: 'Proving your level of English', class: 'govuk-summary-list__key')
      expect(page).to have_element(
        :dd,
        text: 'I have an English as a foreign language (EFL) assessment',
        class: 'govuk-summary-list__value',
      )
      expect(page).to have_element(:dt, text: 'Type of assessment', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: 'EFL Assessment ABC', class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Assessment name', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: 'EFL Assessment ABC', class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Score or grade', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: 'A+', class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Year completed', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: '2020', class: 'govuk-summary-list__value')
    end
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

  def when_i_fill_in_the_ielts_results_form
    fill_in 'Test report form (TRF) number', with: @efl_qualification.trf_number
    fill_in 'Overall band score', with: @efl_qualification.band_score
    fill_in 'When did you complete the assessment?', with: @efl_qualification.award_year
  end
end
