require 'rails_helper'

RSpec.describe 'Change english GCSE' do
  include DfESignInHelpers

  scenario 'Change the english GCSE on an application form', :with_audited do
    given_i_am_a_support_user
    and_there_is_an_application_choice_awaiting_provider_decision

    when_i_visit_the_application_page
    and_i_click_to_change_the_english_gcse
    then_i_see_the_form_to_change_the_applications_english_gcse

    when_i_clear_the_form_inputs
    and_click_on_update_details
    then_i_see_validation_errors_for_each_input

    when_i_select_each_of_the_english_gcses
    and_i_enter_award_year
    and_i_enter_the_zendesk_ticket_url
    and_click_on_update_details
    then_i_see_validation_error_for_entering_any_grade

    when_i_enter_invalid_grades_into_each_english_gcse_input
    and_click_on_update_details
    then_i_see_validation_error_for_entering_invalid_grades

    when_i_enter_valid_grades_into_each_english_gcse_input
    and_click_on_update_details
    then_i_see_the_gcse_grades_have_been_updated
    and_the_english_gcse_has_been_updated
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
    @english_gcse = create(:gcse_qualification, :multiple_english_gcses, application_form: @application_form)

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

  def and_i_click_to_change_the_english_gcse
    within('.app-edit-qualification') do
      click_link_or_button 'Change'
    end
  end

  def then_i_see_the_form_to_change_the_applications_english_gcse
    expect(page).to have_element(:h1, text: 'Edit English GCSE or equivalent')
    expect(page).to have_element(:dt, text: 'Type of qualification')
    expect(page).to have_element(:dd, text: 'GCSE')

    expect(page).to have_element(:legend, text: 'Select the candidate’s GCSEs and grades')
    expect(page).to have_field('support-interface-gcse-form-grade-english-language-field', with: 'A')
    expect(page).to have_field('support-interface-gcse-form-grade-english-literature-field', with: 'D')

    expect(page).to have_field('support-interface-gcse-form-grade-english-single-field')
    expect(page).to have_field('support-interface-gcse-form-grade-english-double-field')
    expect(page).to have_field('support-interface-gcse-form-grade-english-studies-single-field')
    expect(page).to have_field('support-interface-gcse-form-grade-english-studies-double-field')
    expect(page).to have_field('support-interface-gcse-form-other-english-gcse-name-field')
    expect(page).to have_field('support-interface-gcse-form-grade-other-english-gcse-field')

    expect(page).to have_field('Award year', with: @english_gcse.award_year)

    expect(page).to have_field('Zendesk ticket URL')
  end

  def when_i_clear_the_form_inputs
    fill_in 'support-interface-gcse-form-grade-english-language-field', with: nil
    fill_in 'support-interface-gcse-form-grade-english-literature-field', with: nil
    uncheck 'English Language'
    uncheck 'English Literature'
    fill_in 'Award year', with: nil
  end

  def and_click_on_update_details
    click_on 'Update details'
  end

  def then_i_see_validation_errors_for_each_input
    expect(page).to have_element(:h2, text: 'There is a problem')
    within('.govuk-error-summary__body') do
      expect(page).to have_element(:li, text: 'Select at least one GCSE')
      expect(page).to have_element(:li, text: 'Enter the year the candidate gained their qualification')
      expect(page).to have_element(:li, text: 'You must provide an audit comment')
    end
  end

  def when_i_select_each_of_the_english_gcses
    check 'English (Single award)'
    check 'English (Double award)'
    check 'English Language'
    check 'English Literature'
    check 'English Studies (Single award)'
    check 'English Studies (Double award)'
    check 'Other English subject'
  end

  def when_i_select_english_single_award
    check 'English (Single award)'
  end

  def and_i_enter_award_year
    fill_in 'Award year', with: '2024'
  end

  def and_i_enter_the_zendesk_ticket_url
    fill_in 'Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end

  def then_i_see_validation_error_for_entering_any_grade
    expect(page).to have_element(:h2, text: 'There is a problem')
    within('.govuk-error-summary__body') do
      expect(page).to have_element(:li, text: 'Enter the candidate’s English (Single award) grade')
      expect(page).to have_element(:li, text: 'Enter the candidate’s English (Double award) grade')
      expect(page).to have_element(:li, text: 'Enter the candidate’s English Language grade')
      expect(page).to have_element(:li, text: 'Enter the candidate’s English Literature grade')
      expect(page).to have_element(:li, text: 'Enter the candidate’s English Studies (Single award) grade')
      expect(page).to have_element(:li, text: 'Enter the candidate’s English Studies (Double award) grade')
      expect(page).to have_element(:li, text: 'Enter an English GCSE')
      expect(page).to have_element(:li, text: 'Enter the candidate’s other English subject grade')
    end
  end

  def when_i_enter_invalid_grades_into_each_english_gcse_input
    fill_in 'support-interface-gcse-form-grade-english-language-field-error', with: 'Invalid'
    fill_in 'support-interface-gcse-form-grade-english-literature-field-error', with: 'Invalid'
    fill_in 'support-interface-gcse-form-grade-english-single-field-error', with: 'Invalid'
    fill_in 'support-interface-gcse-form-grade-english-double-field-error', with: 'Invalid'
    fill_in 'support-interface-gcse-form-grade-english-studies-single-field-error', with: 'Invalid'
    fill_in 'support-interface-gcse-form-grade-english-studies-double-field-error', with: 'Invalid'
    fill_in 'support-interface-gcse-form-grade-other-english-gcse-field-error', with: 'Invalid'
  end

  def then_i_see_validation_error_for_entering_invalid_grades
    expect(page).to have_element(:h2, text: 'There is a problem')
    within('.govuk-error-summary__body') do
      expect(page).to have_element(:li, text: 'Enter a real English (Single award) grade')
      expect(page).to have_element(:li, text: 'Enter a real English (Double award) grade')
      expect(page).to have_element(:li, text: 'Enter a real English Language grade')
      expect(page).to have_element(:li, text: 'Enter a real English Literature grade')
      expect(page).to have_element(:li, text: 'Enter a real English Studies (Single award) grade')
      expect(page).to have_element(:li, text: 'Enter a real English Studies (Double award) grade')
      expect(page).to have_element(:li, text: 'Enter a real other English subject grade')
    end
  end

  def when_i_enter_valid_grades_into_each_english_gcse_input
    fill_in 'support-interface-gcse-form-grade-english-language-field-error', with: 'C'
    fill_in 'support-interface-gcse-form-grade-english-literature-field-error', with: 'B'
    fill_in 'support-interface-gcse-form-grade-english-single-field-error', with: 'C'
    fill_in 'support-interface-gcse-form-grade-english-double-field-error', with: 'CD'
    fill_in 'support-interface-gcse-form-grade-english-studies-single-field-error', with: 'C'
    fill_in 'support-interface-gcse-form-grade-english-studies-double-field-error', with: 'BC'
    fill_in 'support-interface-gcse-form-other-english-gcse-name-field-error', with: 'Another English GCSE'
    fill_in 'support-interface-gcse-form-grade-other-english-gcse-field-error', with: 'B'
  end

  def then_i_see_the_gcse_grades_have_been_updated
    within('.govuk-notification-banner--success') do
      expect(page).to have_text('GCSE updated')
    end
  end

  def and_the_english_gcse_has_been_updated
    expect(page).to have_element(:h4, text: 'English GCSE')
    expect(page).to have_element(:dt, text: 'Awarded')
    expect(page).to have_element(:dd, text: '2024')
    expect(page).to have_element(:dt, text: 'Grade')
    expect(page).to have_element(:dd, text: 'C (English single award)')
    expect(page).to have_element(:dd, text: 'CD (English double award)')
    expect(page).to have_element(:dd, text: 'C (English language)')
    expect(page).to have_element(:dd, text: 'B (English literature)')
    expect(page).to have_element(:dd, text: 'C (English studies single award)')
    expect(page).to have_element(:dd, text: 'BC (English studies double award)')
    expect(page).to have_element(:dd, text: 'B (Another english gcse)')
  end
end
