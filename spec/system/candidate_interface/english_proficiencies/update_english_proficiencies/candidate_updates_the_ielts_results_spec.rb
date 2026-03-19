require 'rails_helper'

RSpec.describe 'Candidate updates the ielts results' do
  include CandidateHelper

  before do
    Feature.find_or_create_by(name: 'application_form_has_many_english_proficiencies', active: true)
  end

  after do
    FeatureFlag.deactivate(:application_form_has_many_english_proficiencies)
  end

  scenario do
    given_i_am_signed_in_with_one_login
    and_english_is_not_my_first_language
    and_i_have_previous_entered_my_english_proficiency
    and_visit_my_details
    when_i_click_on_english_as_a_foreign_language
    then_i_see_the_review_page
    and_i_see_that_my_level_of_english_is_i_have_an_ielts_efl_assessment

    when_i_click_on_change_trf_number
    then_i_see_the_ielts_results_page
    and_i_see_my_ielts_results_prefilled

    when_i_click_on_back
    then_i_see_the_review_page
    and_i_see_that_my_level_of_english_is_i_have_an_ielts_efl_assessment

    when_i_click_on_change_overall_band_score
    then_i_see_the_ielts_results_page
    and_i_see_my_ielts_results_prefilled

    when_i_click_on_back
    then_i_see_the_review_page
    and_i_see_that_my_level_of_english_is_i_have_an_ielts_efl_assessment

    when_i_click_on_change_year_completed
    then_i_see_the_ielts_results_page
    and_i_see_my_ielts_results_prefilled

    when_i_fill_in_the_ielts_results_form
    and_i_click_on_save_and_continue
    then_i_see_the_review_page
    and_i_see_that_my_ielts_results_have_been_updated
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

  def when_i_click_on_change_trf_number
    click_on 'Change test report form (TRF) number'
  end

  def then_i_see_the_ielts_results_page
    english_proficiency = @application_form.english_proficiencies.last
    expect(page).to have_current_path candidate_interface_english_proficiencies_ielts_path(english_proficiency), ignore_query: true
    expect(page).to have_element(:span, text: 'English as a foreign language assessment', class: 'govuk-caption-xl')
    expect(page).to have_element(:h1, text: 'Your IELTS result', class: 'govuk-heading-xl')
  end

  def and_i_see_my_ielts_results_prefilled
    expect(page).to have_field('Test report form (TRF) number', type: 'text', with: @efl_qualification.trf_number)
    expect(page).to have_field('Overall band score', type: 'text', with: @efl_qualification.band_score)
    expect(page).to have_field('When did you complete the assessment?', type: 'text', with: @efl_qualification.award_year)
  end

  def when_i_click_on_back
    click_on 'Back'
  end

  def when_i_click_on_change_overall_band_score
    click_on 'Change overall band score'
  end

  def when_i_click_on_change_year_completed
    click_on 'Change year completed'
  end

  def when_i_fill_in_the_ielts_results_form
    fill_in 'Test report form (TRF) number', with: 'ABCD1234'
    fill_in 'Overall band score', with: '8'
    fill_in 'When did you complete the assessment?', with: '2020'
  end

  def and_i_click_on_save_and_continue
    click_on 'Save and continue'
  end

  def and_i_see_that_my_ielts_results_have_been_updated
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
end
