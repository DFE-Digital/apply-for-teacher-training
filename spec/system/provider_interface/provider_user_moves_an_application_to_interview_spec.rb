require 'rails_helper'

RSpec.describe 'Provider user sets up an interview', feature_flag: :interview_handling do
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  let(:current_provider) { create(:provider, handle_interviews: :outside_service) }

  scenario 'Provider user has permission to manage the organisation settings' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_sign_in_to_the_provider_interface
    and_an_application_for_the_provider_exists
    when_i_visit_the_application_page
    then_i_see_i_can_move_the_application_to_interview

    when_i_click_on_move_to_interview
    then_i_see_the_application_has_successfully_been_moved_to_interview
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

  def then_i_see_i_can_move_the_application_to_interview
    expect(page).to have_element(:h2, text: 'Set up an interview or make a decision', class: 'govuk-heading-m')
    expect(page).to have_element(:p, text: 'This application was received today. You should try and respond to the candidate within 30 days.')
    expect(page).to have_link('Move to interview')
    expect(page).to have_link('Make decision')

    expect(page).to have_no_link('Set up interview')
  end

  def when_i_click_on_move_to_interview
    click_on 'Move to interview'
  end

  def then_i_see_the_application_has_successfully_been_moved_to_interview
    within('.govuk-notification-banner') do
      expect(page).to have_element(:h2, text: 'Success')
      expect(page).to have_element(:p, text: 'Application moved to Interviewing', class: 'govuk-notification-banner__heading')
    end

    expect(page).to have_element(:strong, text: 'Interviewing', class: 'govuk-tag govuk-tag--yellow')
  end
end
