require 'rails_helper'

RSpec.describe 'Candidate reviews an application with an IELTS qualification',
               feature_flag: '2027_application_form_has_many_english_proficiencies' do
  include CandidateHelper

  scenario 'IELTS qualification' do
    given_i_am_signed_in_with_one_login
    and_english_is_not_my_first_nationality
    and_i_have_an_ielts_qualification
    and_i_have_previously_entered_my_english_proficiency
    and_i_have_an_unsubmitted_application_choice
    when_i_review_my_application
    then_i_can_see_my_ielts_qualification
  end

  scenario 'TOEFL qualification' do
    given_i_am_signed_in_with_one_login
    and_english_is_not_my_first_nationality
    and_i_have_a_toefl_qualification
    and_i_have_previously_entered_my_english_proficiency
    and_i_have_an_unsubmitted_application_choice
    when_i_review_my_application
    then_i_can_see_my_toefl_qualification
  end

  scenario 'Other EFL qualification' do
    given_i_am_signed_in_with_one_login
    and_english_is_not_my_first_nationality
    and_i_have_an_another_efl_qualification
    and_i_have_previously_entered_my_english_proficiency
    and_i_have_an_unsubmitted_application_choice
    when_i_review_my_application
    then_i_can_see_my_efl_qualification
  end

  scenario 'IELTS qualification and English is my first language' do
    given_i_am_signed_in_with_one_login
    and_english_is_not_my_first_nationality
    and_i_have_an_ielts_qualification
    and_i_have_previously_entered_my_english_proficiency
    and_english_is_my_first_language
    and_i_have_an_unsubmitted_application_choice
    when_i_review_my_application
    then_i_can_see_my_ielts_qualification_with_english_is_my_first_language
  end

  scenario 'IELTS qualification and Degree taught in english' do
    given_i_am_signed_in_with_one_login
    and_english_is_not_my_first_nationality
    and_i_have_an_ielts_qualification
    and_i_have_previously_entered_my_english_proficiency
    and_my_degree_was_taught_in_english
    and_i_have_an_unsubmitted_application_choice
    when_i_review_my_application
    then_i_can_see_my_ielts_qualification_with_degree_taught_in_english
  end

  scenario 'IELTS qualification and Degree taught in english and English is my first language' do
    given_i_am_signed_in_with_one_login
    and_english_is_not_my_first_nationality
    and_i_have_an_ielts_qualification
    and_i_have_previously_entered_my_english_proficiency
    and_my_degree_was_taught_in_english
    and_english_is_my_first_language
    and_i_have_an_unsubmitted_application_choice
    when_i_review_my_application
    then_i_can_see_my_ielts_qualification_with_degree_taught_in_english_and_english_is_my_first_language
  end

private

  def and_english_is_not_my_first_nationality
    @application_form = create(
      :application_form,
      :completed,
      :with_degree,
      candidate: current_candidate,
      first_nationality: 'American',
      second_nationality: nil,
      right_to_work_or_study: 'yes',
      immigration_status: 'skilled_worker_visa',
      efl_completed: true,
    )
  end

  def and_i_have_an_ielts_qualification
    @efl_qualification = create(:ielts_qualification)
  end

  def and_i_have_a_toefl_qualification
    @efl_qualification = create(:toefl_qualification)
  end

  def and_i_have_an_another_efl_qualification
    @efl_qualification = create(:other_efl_qualification)
  end

  def and_i_have_previously_entered_my_english_proficiency
    @english_proficiency = create(
      :english_proficiency,
      application_form: @application_form,
      has_qualification: true,
      efl_qualification: @efl_qualification,
    )
  end

  def and_english_is_my_first_language
    @english_proficiency.update!(qualification_not_needed: true)
  end

  def and_my_degree_was_taught_in_english
    @english_proficiency.update!(degree_taught_in_english: true)
  end

  def and_i_have_an_unsubmitted_application_choice
    @application_choice = create(:application_choice, status: 'unsubmitted', application_form: @application_form)
    @course = @application_choice.course
    @course.update!(can_sponsor_student_visa: true, funding_type: 'fee', fee_domestic: 9000, fee_international: 16000)
    @provider = @application_choice.provider
  end

  def when_i_review_my_application
    visit root_path
    click_on 'Your applications'
    click_on @provider.name
    click_on 'Review application'
  end

  def then_i_can_see_my_ielts_qualification
    expect(page).to have_element(
      :h2,
      text: 'English as a foreign language assessment',
      class: 'govuk-summary-card__title',
    )
    expect(page).to have_element(:dt, text: 'Proving your level of English', class: 'govuk-summary-list__key')
    expect(page).to have_element(:dd, text: 'I have an English as a foreign language (EFL) assessment', class: 'govuk-summary-list__value')
    expect(page).to have_element(:dt, text: 'Type of assessment', class: 'govuk-summary-list__key')
    expect(page).to have_element(:dd, text: 'IELTS', class: 'govuk-summary-list__value')
    expect(page).to have_element(:dt, text: 'Test report form (TRF) number', class: 'govuk-summary-list__key')
    expect(page).to have_element(:dd, text: @efl_qualification.trf_number, class: 'govuk-summary-list__value')
    expect(page).to have_element(:dt, text: 'Overall band score', class: 'govuk-summary-list__key')
    expect(page).to have_element(:dd, text: @efl_qualification.band_score, class: 'govuk-summary-list__value')
    expect(page).to have_element(:dt, text: 'Year completed', class: 'govuk-summary-list__key')
    expect(page).to have_element(:dd, text: @efl_qualification.award_year, class: 'govuk-summary-list__value')
  end

  def then_i_can_see_my_toefl_qualification
    expect(page).to have_element(
      :h2,
      text: 'English as a foreign language assessment',
      class: 'govuk-summary-card__title',
    )
    expect(page).to have_element(:dt, text: 'Proving your level of English', class: 'govuk-summary-list__key')
    expect(page).to have_element(:dd, text: 'I have an English as a foreign language (EFL) assessment', class: 'govuk-summary-list__value')
    expect(page).to have_element(:dt, text: 'Type of assessment', class: 'govuk-summary-list__key')
    expect(page).to have_element(:dd, text: 'TOEFL', class: 'govuk-summary-list__value')
    expect(page).to have_element(:dt, text: 'TOEFL registration number', class: 'govuk-summary-list__key')
    expect(page).to have_element(:dd, text: @efl_qualification.registration_number, class: 'govuk-summary-list__value')
    expect(page).to have_element(:dt, text: 'Year completed', class: 'govuk-summary-list__key')
    expect(page).to have_element(:dd, text: @efl_qualification.award_year, class: 'govuk-summary-list__value')
    expect(page).to have_element(:dt, text: 'Total score', class: 'govuk-summary-list__key')
    expect(page).to have_element(:dd, text: @efl_qualification.total_score, class: 'govuk-summary-list__value')
  end

  def then_i_can_see_my_efl_qualification
    expect(page).to have_element(
      :h2,
      text: 'English as a foreign language assessment',
      class: 'govuk-summary-card__title',
    )
    expect(page).to have_element(:dt, text: 'Proving your level of English', class: 'govuk-summary-list__key')
    expect(page).to have_element(:dd, text: 'I have an English as a foreign language (EFL) assessment', class: 'govuk-summary-list__value')
    expect(page).to have_element(:dt, text: 'Type of assessment', class: 'govuk-summary-list__key')
    expect(page).to have_element(:dd, text: @efl_qualification.name, class: 'govuk-summary-list__value')
    expect(page).to have_element(:dt, text: 'Assessment name', class: 'govuk-summary-list__key')
    expect(page).to have_element(:dd, text: @efl_qualification.name, class: 'govuk-summary-list__value')
    expect(page).to have_element(:dt, text: 'Score or grade', class: 'govuk-summary-list__key')
    expect(page).to have_element(:dd, text: @efl_qualification.grade, class: 'govuk-summary-list__value')
    expect(page).to have_element(:dt, text: 'Year completed', class: 'govuk-summary-list__key')
    expect(page).to have_element(:dd, text: @efl_qualification.award_year, class: 'govuk-summary-list__value')
  end

  def then_i_can_see_my_ielts_qualification_with_english_is_my_first_language
    expect(page).to have_element(
      :h2,
      text: 'English as a foreign language assessment',
      class: 'govuk-summary-card__title',
    )
    expect(page).to have_element(:dt, text: 'Proving your level of English', class: 'govuk-summary-list__key')
    expect(page).to have_element(
      :dd,
      text: 'English is my first language I have an English as a foreign language (EFL) assessment',
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

  def then_i_can_see_my_ielts_qualification_with_degree_taught_in_english
    expect(page).to have_element(
      :h2,
      text: 'English as a foreign language assessment',
      class: 'govuk-summary-card__title',
    )
    expect(page).to have_element(:dt, text: 'Proving your level of English', class: 'govuk-summary-list__key')
    expect(page).to have_element(
      :dd,
      text: 'I have an English as a foreign language (EFL) assessment My degree was taught in English',
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

  def then_i_can_see_my_ielts_qualification_with_degree_taught_in_english_and_english_is_my_first_language
    expect(page).to have_element(
      :h2,
      text: 'English as a foreign language assessment',
      class: 'govuk-summary-card__title',
    )
    expect(page).to have_element(:dt, text: 'Proving your level of English', class: 'govuk-summary-list__key')
    expect(page).to have_element(
      :dd,
      text: 'English is my first language I have an English as a foreign language (EFL) assessment My degree was taught in English',
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
