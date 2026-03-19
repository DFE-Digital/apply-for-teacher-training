require 'rails_helper'

RSpec.describe 'Candidate updates their english proficiency to English is my first language' do
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
    and_i_see_that_my_level_of_english_is_i_have_an_efl_assessment

    when_i_click_on_change_level_of_english
    then_i_see_the_proving_your_level_of_english_page
    and_i_see_i_have_an_efl_assessment_selected

    when_i_unselect_i_have_an_efl_assessment
    and_i_select_english_is_my_first_language
    and_i_click_on_continue
    then_i_see_the_review_page
    and_i_see_that_english_is_my_first_language
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
      expect(page).to have_element(:dd, text: @efl_qualification.trf_number, class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Overall band score', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: @efl_qualification.band_score, class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Year completed', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: @efl_qualification.award_year, class: 'govuk-summary-list__value')
    end
  end

  def when_i_click_on_change_level_of_english
    click_on 'Change level of english'
  end

  def then_i_see_the_proving_your_level_of_english_page
    expect(page).to have_current_path candidate_interface_english_proficiencies_edit_start_path(@english_proficiency)
    expect(page).to have_element(:span, text: 'English as a foreign language assessment', class: 'govuk-caption-xl')
    expect(page).to have_element(:h1, text: 'Proving your level of English', class: 'govuk-fieldset__heading')

    expect(page).to have_field('English is my first language', type: 'checkbox')
    expect(page).to have_field('My degree was taught in English', type: 'checkbox')
    expect(page).to have_field('I have an English as a foreign language (EFL) assessment', type: 'checkbox')
    expect(page).to have_field('None of these', type: 'checkbox')
  end

  def and_i_see_i_have_an_efl_assessment_selected
    expect(page).to have_checked_field('I have an English as a foreign language (EFL) assessment', type: 'checkbox')
  end

  def when_i_unselect_i_have_an_efl_assessment
    uncheck 'I have an English as a foreign language (EFL) assessment'
  end

  def and_i_select_english_is_my_first_language
    check 'English is my first language'
  end

  def and_i_click_on_continue
    click_on 'Continue'
  end

  def and_i_see_that_english_is_my_first_language
    within('.govuk-summary-card') do
      expect(page).to have_element(:h2, text: 'English as a foreign language assessment', class: 'govuk-summary-card__title')
      expect(page).to have_element(:dt, text: 'Proving your level of English', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: 'English is my first language', class: 'govuk-summary-list__value')
    end
  end
end
