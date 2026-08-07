require 'rails_helper'

RSpec.describe 'Change science GCSE' do
  include DfESignInHelpers

  scenario 'Change the science GCSE on an application form', :with_audited do
    given_i_am_a_support_user
    and_there_is_an_application_choice_awaiting_provider_decision

    when_i_visit_the_application_page
    and_i_click_to_change_the_science_gcse
    then_i_see_the_form_to_change_the_applications_science_gcse

    when_i_clear_the_form_inputs
    and_click_on_update_details
    then_i_see_validation_errors_for_the_blank_single_award

    when_i_select_double_award
    and_click_on_update_details
    then_i_see_validation_errors_for_the_blank_double_award

    when_i_select_triple_award
    and_click_on_update_details
    then_i_see_validation_errors_for_the_blank_triple_award_grades

    when_i_select_single_award
    and_i_enter_an_invalid_single_award_grade
    and_click_on_update_details
    then_i_see_validation_error_for_the_invalid_single_award_grade

    when_i_select_double_award
    and_i_enter_an_invalid_double_award_grade
    and_click_on_update_details
    then_i_see_validation_error_for_the_invalid_double_award_grade

    when_i_select_triple_award
    and_i_enter_an_invalid_triple_award_grades
    and_click_on_update_details
    then_i_see_validation_error_for_the_invalid_triple_award_grade

    when_i_select_double_award
    and_i_enter_valid_a_input_for_the_double_award_grade
    and_i_enter_valid_inputs_for_the_award_year_and_zendesk_ticket_url

    # then_i_see_the_gcse_grades_have_been_updated
    # and_the_science_gcse_has_been_updated
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
    @science_gcse = create(
      :gcse_qualification,
      :science_gcse,
      subject: 'science single award',
      application_form: @application_form,
    )

    @application_choice = create(
      :application_choice,
      :awaiting_provider_decision,
      application_form: @application_form,
    )
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@application_choice.application_form_id)
  end

  def and_i_click_to_change_the_science_gcse
    within('.app-edit-qualification') do
      click_link_or_button 'Change'
    end
  end

  def then_i_see_the_form_to_change_the_applications_science_gcse
    expect(page).to have_element(:h1, text: 'Edit science GCSE or equivalent')
    expect(page).to have_element(:dt, text: 'Type of qualification')
    expect(page).to have_element(:dd, text: 'GCSE')

    expect(page).to have_element(:legend, text: 'Select the candidate’s GCSEs and grades')
    expect(page).to have_field('Single award', type: :radio, checked: true)
    expect(page).to have_field('support-interface-gcse-form-single-award-grade-field', with: @science_gcse.grade)
    expect(page).to have_field('Double award', type: :radio)
    expect(page).to have_field('Triple award', type: :radio)

    expect(page).to have_field('Award year', with: @science_gcse.award_year)

    expect(page).to have_field('Zendesk ticket URL')
  end

  def when_i_clear_the_form_inputs
    fill_in 'support-interface-gcse-form-single-award-grade-field', with: nil
    fill_in 'Award year', with: nil
  end

  def and_click_on_update_details
    click_on 'Update details'
  end

  def then_i_see_validation_errors_for_the_blank_single_award
    expect(page).to have_element(:h2, text: 'There is a problem')
    within('.govuk-error-summary__body') do
      expect(page).to have_element(:li, text: 'Enter the candidate’s single award grade')
    end
    and_i_see_validation_errors_for_blank_award_year_and_zendesk_ticket_url
  end

  def and_i_see_validation_errors_for_blank_award_year_and_zendesk_ticket_url
    expect(page).to have_element(:h2, text: 'There is a problem')
    within('.govuk-error-summary__body') do
      expect(page).to have_element(:li, text: 'Enter the year the candidate gained their qualification')
      expect(page).to have_element(:li, text: 'You must provide an audit comment')
    end
  end

  def when_i_select_double_award
    choose 'Double award'
  end

  def then_i_see_validation_errors_for_the_blank_double_award
    expect(page).to have_element(:h2, text: 'There is a problem')
    within('.govuk-error-summary__body') do
      expect(page).to have_element(:li, text: 'Enter the candidate’s double award grade')
    end
    and_i_see_validation_errors_for_blank_award_year_and_zendesk_ticket_url
  end

  def when_i_select_triple_award
    choose 'Triple award'
  end

  def then_i_see_validation_errors_for_the_blank_triple_award_grades
    expect(page).to have_element(:h2, text: 'There is a problem')
    within('.govuk-error-summary__body') do
      expect(page).to have_element(:li, text: 'Enter the candidate’s biology grade')
      expect(page).to have_element(:li, text: 'Enter the candidate’s chemistry grade')
      expect(page).to have_element(:li, text: 'Enter the candidate’s physics grade')
    end
    and_i_see_validation_errors_for_blank_award_year_and_zendesk_ticket_url
  end

  def when_i_select_single_award
    choose 'Single award'
  end

  def and_i_enter_an_invalid_single_award_grade
    fill_in 'support-interface-gcse-form-single-award-grade-field', with: 'Invalid'
  end

  def then_i_see_validation_error_for_the_invalid_single_award_grade
    expect(page).to have_element(:h2, text: 'There is a problem')
    within('.govuk-error-summary__body') do
      expect(page).to have_element(:li, text: 'Enter a real single award grade')
    end
  end

  def and_i_enter_an_invalid_double_award_grade
    fill_in 'support-interface-gcse-form-double-award-grade-field', with: 'Invalid'
  end

  def then_i_see_validation_error_for_the_invalid_double_award_grade
    expect(page).to have_element(:h2, text: 'There is a problem')
    within('.govuk-error-summary__body') do
      expect(page).to have_element(:li, text: 'Enter a real double award grade')
    end
  end

  def and_i_enter_an_invalid_triple_award_grades
    fill_in 'support-interface-gcse-form-biology-grade-field', with: 'Invalid'
    fill_in 'support-interface-gcse-form-chemistry-grade-field', with: 'Invalid'
    fill_in 'support-interface-gcse-form-physics-grade-field', with: 'Invalid'
  end

  def then_i_see_validation_error_for_the_invalid_triple_award_grade
    expect(page).to have_element(:h2, text: 'There is a problem')
    within('.govuk-error-summary__body') do
      expect(page).to have_element(:li, text: 'Enter a real biology grade')
      expect(page).to have_element(:li, text: 'Enter a real chemistry grade')
      expect(page).to have_element(:li, text: 'Enter a real physics grade')
    end
  end

  def and_i_enter_valid_a_input_for_the_double_award_grade
    fill_in 'support-interface-gcse-form-double-award-grade-field', with: 'CD'
  end

  def and_i_enter_valid_inputs_for_the_award_year_and_zendesk_ticket_url
    fill_in 'Award year', with: '2018'
    fill_in 'Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end

  def then_i_see_the_gcse_grades_have_been_updated
    within('.govuk-notification-banner--success') do
      expect(page).to have_text('GCSE updated')
    end
  end

  def and_the_science_gcse_has_been_updated
    expect(page).to have_element(:h4, text: 'Science GCSE')
    expect(page).to have_element(:dt, text: 'Awarded')
    expect(page).to have_element(:dd, text: '2018')
    expect(page).to have_element(:dt, text: 'Grade')
    expect(page).to have_element(:dd, text: 'CD')
  end
end
