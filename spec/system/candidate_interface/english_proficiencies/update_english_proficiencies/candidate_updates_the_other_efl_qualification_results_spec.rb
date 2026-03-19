require 'rails_helper'

RSpec.describe 'Candidate updates the other efl qualification results' do
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

    when_i_click_on_change_assessment_name
    then_i_see_the_other_efl_results_page
    and_i_see_my_other_efl_qualification_results_prefilled

    when_i_click_on_back
    then_i_see_the_review_page
    and_i_see_that_my_level_of_english_is_i_have_an_efl_assessment

    when_i_click_on_change_score_or_grade
    then_i_see_the_other_efl_results_page
    and_i_see_my_other_efl_qualification_results_prefilled

    when_i_click_on_back
    then_i_see_the_review_page
    and_i_see_that_my_level_of_english_is_i_have_an_efl_assessment

    when_i_click_on_change_year_completed
    then_i_see_the_other_efl_results_page
    and_i_see_my_other_efl_qualification_results_prefilled

    when_i_fill_in_the_other_efl_results_form
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
    @efl_qualification = create(:other_efl_qualification)
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
      expect(page).to have_element(:dd, text: @efl_qualification.name, class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Assessment name', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: @efl_qualification.name, class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Score or grade', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: @efl_qualification.grade, class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Year completed', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: @efl_qualification.award_year, class: 'govuk-summary-list__value')
    end
  end

  def when_i_click_on_change_assessment_name
    click_on 'Change assessment name'
  end

  def then_i_see_the_other_efl_results_page
    english_proficiency = @application_form.english_proficiencies.last
    expect(page).to have_current_path candidate_interface_english_proficiencies_other_efl_qualification_path(english_proficiency), ignore_query: true
    expect(page).to have_element(:span, text: 'English as a foreign language assessment', class: 'govuk-caption-xl')
    expect(page).to have_element(:h1, text: 'Your English language assessment result', class: 'govuk-heading-xl')
  end

  def and_i_see_my_other_efl_qualification_results_prefilled
    expect(page).to have_field('Assessment name', type: 'text', with: @efl_qualification.name)
    expect(page).to have_field('Score or grade', type: 'text', with: @efl_qualification.grade)
    expect(page).to have_field('When did you complete the assessment?', type: 'text', with: @efl_qualification.award_year)
  end

  def when_i_click_on_back
    click_on 'Back'
  end

  def when_i_click_on_change_score_or_grade
    click_on 'Change score or grade'
  end

  def when_i_click_on_change_year_completed
    click_on 'Change year completed'
  end

  def when_i_fill_in_the_other_efl_results_form
    fill_in 'Assessment name', with: 'EFL Assessment ABC'
    fill_in 'Score or grade', with: 'A+'
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
      expect(page).to have_element(:dd, text: 'EFL Assessment ABC', class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Assessment name', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: 'EFL Assessment ABC', class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Score or grade', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: 'A+', class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Year completed', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: '2020', class: 'govuk-summary-list__value')
    end
  end
end
