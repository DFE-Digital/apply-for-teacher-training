require 'rails_helper'

RSpec.describe 'Change science GCSE' do
  include DfESignInHelpers

  scenario 'Change the science O level on an application form', :with_audited do
    given_i_am_a_support_user
    and_there_is_an_application_choice_awaiting_provider_decision

    when_i_visit_the_application_page
    and_i_click_to_change_the_science_o_level
    then_i_see_the_form_to_change_the_applications_science_o_level

    when_i_clear_the_form_inputs
    and_click_on_update_details
    then_i_see_validation_errors_for_each_input

    when_i_enter_invalid_inputs
    and_click_on_update_details
    then_i_see_validation_error_for_entering_invalid_inputs

    when_i_enter_an_award_year_after_1987
    and_click_on_update_details
    then_i_see_validation_error_for_entering_a_year_after_1987

    when_i_enter_valid_inputs
    and_click_on_update_details
    then_i_see_the_gcse_grades_have_been_updated
    and_the_science_o_level_has_been_updated
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
      subject: 'science',
      qualification_type: 'gce_o_level',
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

  def then_i_see_a_change_english_link
    expect(page).to have_link('Change')
  end

  def and_i_click_to_change_the_science_o_level
    within('.app-edit-qualification') do
      click_link_or_button 'Change'
    end
  end

  def then_i_see_the_form_to_change_the_applications_science_o_level
    expect(page).to have_element(:h1, text: 'Edit science GCSE or equivalent')
    expect(page).to have_element(:dt, text: 'Type of qualification')
    expect(page).to have_element(:dd, text: 'UK O level (from before 1989)')

    expect(page).to have_field('Grade', with: @science_gcse.grade)
    expect(page).to have_field('Award year', with: @science_gcse.award_year)
    expect(page).to have_field('Zendesk ticket URL')
  end

  def when_i_clear_the_form_inputs
    fill_in 'Grade', with: nil
    fill_in 'Award year', with: nil
    fill_in 'Zendesk ticket URL', with: nil
  end

  def and_click_on_update_details
    click_on 'Update details'
  end

  def then_i_see_validation_errors_for_each_input
    expect(page).to have_element(:h2, text: 'There is a problem')
    within('.govuk-error-summary__body') do
      expect(page).to have_element(:li, text: 'Enter the candidate’s grade')
      expect(page).to have_element(:li, text: 'Enter the year the candidate gained their qualification')
      expect(page).to have_element(:li, text: 'You must provide an audit comment')
    end
  end

  def when_i_enter_invalid_inputs
    fill_in 'Award year', with: 'Invalid'
    fill_in 'Zendesk ticket URL', with: 'Invalid'
  end

  def then_i_see_validation_error_for_entering_invalid_inputs
    expect(page).to have_element(:h2, text: 'There is a problem')
    within('.govuk-error-summary__body') do
      expect(page).to have_element(:li, text: 'Enter a real award year')
      expect(page).to have_element(:li, text: 'Enter a valid Zendesk ticket URL')
    end
  end

  def when_i_enter_an_award_year_after_1987
    fill_in 'Award year', with: '2018'
  end

  def then_i_see_validation_error_for_entering_a_year_after_1987
    expect(page).to have_element(:h2, text: 'There is a problem')
    within('.govuk-error-summary__body') do
      expect(page).to have_element(:li, text: 'Enter a year before 1989 - GCSEs replaced O levels in 1988')
    end
  end

  def when_i_enter_valid_inputs
    fill_in 'Grade', with: 'B'
    fill_in 'Award year', with: 1987
    fill_in 'Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end

  def then_i_see_the_gcse_grades_have_been_updated
    within('.govuk-notification-banner--success') do
      expect(page).to have_text('GCSE updated')
    end
  end

  def and_the_science_o_level_has_been_updated
    expect(page).to have_element(:h4, text: 'Science UK O level (from before 1989)')
    expect(page).to have_element(:dt, text: 'Awarded')
    expect(page).to have_element(:dd, text: '1987')
    expect(page).to have_element(:dt, text: 'Grade')
    expect(page).to have_element(:dd, text: 'B')
  end
end
