require 'rails_helper'

RSpec.describe 'Provider user sets up an interview', feature_flag: :interview_handling do
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  let(:current_provider) { create(:provider) }

  scenario 'Provider user has permission to manage the organisation settings', :with_cache do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_sign_in_to_the_provider_interface
    and_an_application_for_the_provider_exists
    when_i_visit_the_application_page
    then_i_see_i_can_set_up_an_interview

    when_i_click_on_set_up_interview
    then_i_see_the_interview_details_page

    when_i_fill_in_the_interview_details_form
    and_i_click_on_continue
    then_i_see_the_interview_details_summary_page

    when_i_click_on_send_interview_details
    then_i_see_the_interview_have_been_successfully_set_up
  end

private

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    @provider_user = provider_user_exists_in_apply_database(provider_code: current_provider.code)
    permit_make_decisions!
    permit_set_up_interviews!
  end

  def and_an_application_for_the_provider_exists
    course_option = create(:course_option, course: create(:course, provider: current_provider))
    @application_choice = create(
      :application_choice,
      :with_submitted_application_form,
      provider_ids: [current_provider.id],
      status: :awaiting_provider_decision,
      course_option:,
      reject_by_default_at: 3.months.from_now,
    )
  end

  def when_i_visit_the_application_page
    visit provider_interface_application_choice_path(@application_choice)
  end

  def then_i_see_i_can_set_up_an_interview
    expect(page).to have_element(:h2, text: 'Set up an interview or make a decision', class: 'govuk-heading-m')
    expect(page).to have_element(:p, text: 'This application was received today. You should try and respond to the candidate within 30 days.')
    expect(page).to have_link('Set up interview')
    expect(page).to have_link('Make decision')

    expect(page).to have_no_link('Move to interview')
  end

  def when_i_click_on_set_up_interview
    click_on 'Set up interview'
  end

  def then_i_see_the_interview_details_page
    expect(page).to have_current_path(new_provider_interface_application_choice_interview_path(@application_choice))
    expect(page).to have_element(:h1, text: 'Set up an interview', class: 'govuk-heading-l')
    expect(page).to have_element(
      :div,
      text: 'Details of when this candidate is not available for interview',
      class: 'app-banner app-banner--details',
    )

    expect(page).to have_field('Day', type: :text)
    expect(page).to have_field('Month', type: :text)
    expect(page).to have_field('Year', type: :text)
    expect(page).to have_field('Start time', type: :text)
    expect(page).to have_field('Address or online meeting details', type: :textarea)
    expect(page).to have_field('Additional details (optional)', type: :textarea)
  end

  def when_i_fill_in_the_interview_details_form
    @interview_date = 1.month.from_now
    fill_in 'Day', with: @interview_date.day
    fill_in 'Month', with: @interview_date.month
    fill_in 'Year', with: @interview_date.year
    fill_in 'Start time', with: '14:00'
    fill_in 'Address or online meeting details', with: 'London Office'
  end

  def and_i_click_on_continue
    click_on 'Continue'
  end

  def then_i_see_the_interview_details_summary_page
    expect(page).to have_element(:h1, text: 'Check and send interview details', class: 'govuk-heading-l')
    within('.govuk-summary-list') do
      expect(page).to have_element(:dt, text: 'Date', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: @interview_date.strftime('%e %B %Y').strip, class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Start time', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: '2pm UK time', class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Organisation carrying out interview', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: current_provider.name, class: 'govuk-summary-list__value')
      expect(page).to have_element(:dt, text: 'Address or online meeting details', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: 'London Office', class: 'govuk-summary-list__value')
    end
  end

  def when_i_click_on_send_interview_details
    click_on 'Send interview details'
  end

  def then_i_see_the_interview_have_been_successfully_set_up
    within('.govuk-notification-banner') do
      expect(page).to have_element(:h2, text: 'Success')
      expect(page).to have_element(:p, text: 'Interview set up', class: 'govuk-notification-banner__heading')
      expect(page).to have_element(
        :p,
        text: 'To move candidates to interviewing without adding interview details, update your organisation settings.',
        class: 'govuk-body',
      )
      expect(page).to have_link('organisation settings', href: '/provider/organisation-settings')
    end
  end
end
