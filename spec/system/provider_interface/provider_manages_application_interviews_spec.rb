require 'rails_helper'

RSpec.describe 'A Provider viewing an individual application', with_audited: true do
  include CourseOptionHelpers
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  let(:application_choice) { create(:application_choice, :awaiting_provider_decision, course_option: course_option) }
  let(:course_option) { course_option_for_provider_code(provider_code: 'ABC') }

  around do |example|
    Timecop.freeze(Time.zone.local(2020, 3, 1, 12, 0, 0)) do
      example.run
    end
  end

  before do
    FeatureFlag.activate(:interviews)
  end

  scenario 'can view, create and cancel interviews' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_i_am_permitted_to_make_decisions_for_my_provider
    and_i_sign_in_to_the_provider_interface

    when_i_visit_that_application_in_the_provider_interface
    i_can_set_up_an_interview
    and_i_can_set_up_another_interview

    when_i_cancel_an_interview
    i_can_see_the_application_is_still_in_the_interviewing_state
    and_i_can_see_the_second_interview

    when_i_cancel_an_interview
    i_can_see_the_application_is_awaiting_provider_decision
    and_the_interview_tab_is_not_available
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_for_my_provider
    provider_user_exists_in_apply_database
  end

  def and_i_am_permitted_to_make_decisions_for_my_provider
    permit_make_decisions!
  end

  def when_i_visit_that_application_in_the_provider_interface
    visit provider_interface_application_choice_path(application_choice)
  end

  def i_can_set_up_an_interview
    visit new_provider_interface_application_choice_interview_path(application_choice, date_and_time: '2021-2-4')
    expect(page).to have_content('Interview successfully created')
  end

  alias_method :and_i_can_set_up_another_interview, :i_can_set_up_an_interview

  def when_i_cancel_an_interview
    visit provider_interface_application_choice_interviews_path(application_choice)

    first(:link, 'Cancel').click
    fill_in 'interview[cancellation_reason]', with: 'A cancellation reason'
    click_on 'Continue'

    click_on 'Send cancellation'
    expect(page).to have_content('Interview cancelled')
  end

  def i_can_see_the_application_is_still_in_the_interviewing_state
    expect(page).to have_content('Interviewing')
  end

  def and_i_can_see_the_second_interview
    visit provider_interface_application_choice_interviews_path(application_choice)

    expect(page).to have_content('Upcoming interviews')
    expect(page).to have_css('.app-interviews__interview')
  end

  def i_can_see_the_application_is_awaiting_provider_decision
    expect(page).to have_content('Received')
  end

  def and_the_interview_tab_is_not_available
    within '.app-tab-navigation__list' do
      expect(page).not_to have_content('Interviews')
    end
  end
end
