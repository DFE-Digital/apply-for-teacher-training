require 'rails_helper'

RSpec.describe 'Change english GCSE' do
  include DfESignInHelpers

  scenario 'Change the missing english GCSE details on an application form', :with_audited do
    given_i_am_a_support_user
    and_there_is_an_application_choice_awaiting_provider_decision

    when_i_visit_the_application_page
    and_i_click_to_change_the_missing_english_gcse
    then_i_see_the_form_to_change_the_applications_missing_english_gcse

    when_i_clear_the_form_inputs
    and_click_on_update_details
    then_i_see_validation_errors_for_each_input

    when_i_enter_invalid_details_for_the_qualification_the_candidate_is_studying
    and_click_on_update_details
    then_i_see_validation_error_for_entering_an_invalid_details_for_the_qualification_the_candidate_is_studying

    when_i_enter_valid_details_of_the_qualification_the_candidate_is_studying
    and_i_enter_a_zendesk_link
    and_click_on_update_details
    then_i_see_the_gcse_grades_have_been_updated
    and_the_missing_english_gcse_details_have_been_updated

    when_i_click_to_change_the_missing_english_gcse
    and_i_select_no_to_studying_a_gcse
    and_i_enter_other_evidence_of_having_english_skills
    and_i_enter_a_zendesk_link
    and_click_on_update_details
    and_the_missing_english_gcse_details_have_been_updated_with_other_evidence
  end

private

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_an_application_choice_awaiting_provider_decision
    @application_form = create(
      :application_form,
      submitted_at: Time.zone.now,
    )
    @english_gcse = create(:gcse_qualification, :missing_and_currently_completing, subject: 'english', application_form: @application_form)

    @application_choice = create(
      :application_choice,
      :awaiting_provider_decision,
      application_form: @application_form,
    )
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@application_choice.application_form_id)
  end

  def then_i_see_a_change_english_link
    expect(page).to have_link('Change')
  end

  def and_i_click_to_change_the_missing_english_gcse
    within('.app-edit-qualification') do
      click_link_or_button 'Change'
    end
  end
  alias_method :when_i_click_to_change_the_missing_english_gcse, :and_i_click_to_change_the_missing_english_gcse

  def then_i_see_the_form_to_change_the_applications_missing_english_gcse
    expect(page).to have_element(:h1, text: 'Edit English GCSE or equivalent')

    expect(page).to have_element(:legend, text: 'What type of qualification in English do you have?')
    expect(page).to have_field('GCSE', type: 'radio')
    expect(page).to have_field('UK O level (from before 1989)', type: 'radio')
    expect(page).to have_field('Scottish National 5', type: 'radio')
    expect(page).to have_field('Another UK qualification', type: 'radio')
    expect(page).to have_field('Qualification from outside the UK', type: 'radio')
    expect(page).to have_field('I do not have a qualification in English yet', type: 'radio', checked: true)

    expect(page).to have_element(:legend, text: 'Are you currently studying for a GCSE in English, or equivalent?')
    expect(page).to have_field('Yes', type: 'radio', checked: true)
    expect(page).to have_field('Details of the qualification you are studying for', with: @english_gcse.not_completed_explanation)
    expect(page).to have_field('No', type: 'radio', checked: false)
    expect(page).to have_field(
      'If you have other evidence of having English skills at the required standard, give details (optional)',
      visible: :all,
    )

    expect(page).to have_field('Grade')
    expect(page).to have_field('Award year')
    expect(page).to have_field('Zendesk ticket URL')
  end

  def when_i_clear_the_form_inputs
    fill_in 'Details of the qualification you are studying for', with: nil
    fill_in 'Zendesk ticket URL', with: nil
  end

  def and_click_on_update_details
    click_on 'Update details'
  end

  def then_i_see_validation_errors_for_each_input
    expect(page).to have_element(:h2, text: 'There is a problem')
    within('.govuk-error-summary__body') do
      expect(page).to have_element(:li, text: 'Enter details of the qualification the candidate is studying for')
      expect(page).to have_element(:li, text: 'You must provide an audit comment')
    end
  end

  def when_i_enter_invalid_details_for_the_qualification_the_candidate_is_studying
    fill_in 'Details of the qualification you are studying for', with: 'a' * 266
  end

  def then_i_see_validation_error_for_entering_an_invalid_details_for_the_qualification_the_candidate_is_studying
    expect(page).to have_element(:h2, text: 'There is a problem')
    within('.govuk-error-summary__body') do
      expect(page).to have_element(:li, text: 'Qualification details must be 256 characters or fewer')
    end
  end

  def when_i_enter_valid_details_of_the_qualification_the_candidate_is_studying
    fill_in 'Details of the qualification you are studying for', with: 'Studying a GCSE'
  end

  def and_i_enter_a_zendesk_link
    fill_in 'Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end

  def then_i_see_the_gcse_grades_have_been_updated
    within('.govuk-notification-banner--success') do
      expect(page).to have_text('GCSE updated')
    end
  end

  def and_the_missing_english_gcse_details_have_been_updated
    expect(page).to have_element(:h4, text: 'English')
    expect(page).to have_element(:dd, text: 'Candidate does not have this qualification yet')
    expect(page).to have_element(:dt, text: 'Details of qualification currently studying for')
    expect(page).to have_element(:dd, text: 'Studying a GCSE')
  end

  def and_i_select_no_to_studying_a_gcse
    choose 'No'
  end

  def and_i_enter_other_evidence_of_having_english_skills
    fill_in 'If you have other evidence of having English skills at the required standard, give details (optional)',
            with: 'English is my main language'
  end

  def and_the_missing_english_gcse_details_have_been_updated_with_other_evidence
    expect(page).to have_element(:h4, text: 'English')
    expect(page).to have_element(:dd, text: 'Candidate does not have this qualification yet')
    expect(page).to have_element(:dt, text: 'Other evidence I have the skills required')
    expect(page).to have_element(:dd, text: 'English is my main language')
  end
end
