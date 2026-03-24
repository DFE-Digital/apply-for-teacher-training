require 'rails_helper'

RSpec.describe 'Candidate reviews an application with no EFL qualification',
               feature_flag: '2027_application_form_has_many_english_proficiencies' do
  include CandidateHelper

  scenario 'with no details' do
    given_i_am_signed_in_with_one_login
    and_english_is_not_my_first_nationality
    and_i_have_previously_entered_my_english_proficiency
    and_i_have_an_unsubmitted_application_choice
    when_i_review_my_application
    then_i_can_see_a_degree_taught_in_english_with_no_details
  end

  scenario 'with details' do
    given_i_am_signed_in_with_one_login
    and_english_is_not_my_first_nationality
    and_i_have_previously_entered_my_english_proficiency
    and_i_have_given_details_of_my_efl_assessment
    and_i_have_an_unsubmitted_application_choice
    when_i_review_my_application
    then_i_can_see_a_degree_taught_in_english_with_details
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

  def and_i_have_previously_entered_my_english_proficiency
    @english_proficiency = create(
      :english_proficiency,
      application_form: @application_form,
      no_qualification: true,
      efl_qualification: @efl_qualification,
    )
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

  def then_i_can_see_a_degree_taught_in_english_with_no_details
    expect(page).to have_element(
      :h3,
      text: 'English as a foreign language assessment',
      class: 'govuk-summary-card__title',
    )
    expect(page).to have_element(:dt, text: 'Proving your level of English', class: 'govuk-summary-list__key')
    expect(page).to have_element(
      :dd,
      text: 'None of these',
      class: 'govuk-summary-list__value',
    )
    expect(page).to have_element(
      :dt,
      text: 'Do you plan on taking an English as a foreign language assessment?',
      class: 'govuk-summary-list__key',
    )
    expect(page).to have_element(:dd, text: 'No', class: 'govuk-summary-list__value')
  end

  def and_i_have_given_details_of_my_efl_assessment
    @english_proficiency.update!(no_qualification_details: 'Work in progress')
  end

  def then_i_can_see_a_degree_taught_in_english_with_details
    expect(page).to have_element(
      :h3,
      text: 'English as a foreign language assessment',
      class: 'govuk-summary-card__title',
    )
    expect(page).to have_element(:dt, text: 'Proving your level of English', class: 'govuk-summary-list__key')
    expect(page).to have_element(
      :dd,
      text: 'None of these',
      class: 'govuk-summary-list__value',
    )
    expect(page).to have_element(
      :dt,
      text: 'Do you plan on taking an English as a foreign language assessment?',
      class: 'govuk-summary-list__key',
    )
    expect(page).to have_element(:dd, text: 'Yes', class: 'govuk-summary-list__value')
    expect(page).to have_element(:dt, text: 'Details', class: 'govuk-summary-list__key')
    expect(page).to have_element(:dd, text: 'Work in progress', class: 'govuk-summary-list__value')
  end
end
