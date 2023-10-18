require 'rails_helper'

RSpec.feature 'See updated applications post-submission' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'Notifications and indicators are visible', :with_audited do
    given_i_am_a_provider_user_authenticated_with_dfe_sign_in
    and_my_apply_account_has_been_created
    and_my_organisation_has_two_submitted_applications

    when_1_day_passes
    then_the_updated_long_ago_application_has_the_address_updated

    when_1_month_passes
    then_the_updated_recently_application_has_the_address_updated

    when_1_month_passes

    and_i_sign_in_to_the_provider_interface
    then_i_should_see_the_applications_from_my_organisation

    # Visit the recently updated application
    when_i_click_on_the_recently_updated_application
    then_i_should_be_on_the_application_view_page
    and_i_should_see_the_updated_recently_notification

    # Visit the application updated long ago
    when_i_click_on_applications_in_the_navigation_bar
    and_i_visit_the_updated_long_ago_application
    then_i_should_not_see_the_updated_recently_notification
  end

  def and_my_apply_account_has_been_created
    provider_user_exists_in_apply_database(provider_code: 'ABC')
  end

  def given_i_am_a_provider_user_authenticated_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_signs_in_using_dfe_sign_in
  end

  def then_the_updated_recently_application_has_the_address_updated
    @updated_recently.application_form.update(address_line1: '123 Fake Street')
  end

  def then_the_updated_long_ago_application_has_the_address_updated
    @updated_long_ago.application_form.update(address_line1: '123 Fake Street')
  end

  def when_1_day_passes
    TestSuiteTimeMachine.travel_permanently_to(1.day.from_now)
  end

  def when_1_month_passes
    TestSuiteTimeMachine.travel_permanently_to(1.month.from_now)
  end

  def and_my_organisation_has_two_submitted_applications
    course_option = course_option_for_provider_code(provider_code: 'ABC')

    @updated_recently = create(:application_choice,
                               :awaiting_provider_decision,
                               course_option:)
    @updated_long_ago = create(:application_choice,
                               :awaiting_provider_decision,
                               :with_completed_application_form,
                               course_option:)
  end

  def then_i_should_see_the_applications_from_my_organisation
    expect(page).to have_title 'Applications (2)'
    expect(page).to have_content 'Applications (2)'
    expect(page).to have_content @updated_long_ago.application_form.full_name
    expect(page).to have_content @updated_recently.application_form.full_name
  end

  def when_i_click_on_the_recently_updated_application
    click_link @updated_recently.application_form.full_name
  end

  def then_i_should_be_on_the_application_view_page
    expect(page).to have_content @updated_recently.id

    expect(page).to have_content @updated_recently.application_form.full_name
  end

  def and_i_should_see_the_updated_recently_notification
    expect(page).to have_content 'View the timeline for their updates'
  end

  def then_i_should_not_see_the_updated_recently_notification
    expect(page).not_to have_content 'View the timeline for their updates'
  end

  def and_i_visit_the_updated_long_ago_application
    click_link @updated_long_ago.application_form.full_name
  end

  def when_i_click_on_applications_in_the_navigation_bar
    within '.app-primary-navigation' do
      click_link 'Applications'
    end
  end
end
