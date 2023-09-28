require 'rails_helper'

RSpec.describe 'Reject an application with interviews' do
  include DfESignInHelpers
  include ProviderUserPermissionsHelper
  include CourseOptionHelpers

  scenario 'giving reasons for rejection' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_i_am_permitted_to_make_decisions_on_applications_for_my_provider
    and_my_organisation_has_received_an_application_with_an_upcoming_interview
    and_i_sign_in_to_the_provider_interface

    when_i_respond_to_an_application
    and_i_choose_to_reject_it

    then_i_give_reasons_why_i_am_rejecting_the_application
    and_the_cancellation_of_interviews_message_is_shown
    and_i_submit_the_reasons_for_rejection
    and_the_interview_is_cancelled
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_for_my_provider
    provider_user_exists_in_apply_database
  end

  def and_i_am_permitted_to_make_decisions_on_applications_for_my_provider
    permit_make_decisions!
  end

  def and_my_organisation_has_received_an_application_with_an_upcoming_interview
    course_option = course_option_for_provider_code(provider_code: 'ABC')
    @application_choice = create(:application_choice, :awaiting_provider_decision, course_option:)
    @interview = create(:interview, application_choice: @application_choice, date_and_time: 2.days.from_now)
  end

  def when_i_respond_to_an_application
    visit provider_interface_application_choice_path(@application_choice)
    click_link 'Make decision'
  end

  def and_i_choose_to_reject_it
    choose 'Reject application'
    click_button t('continue')
  end

  def then_i_give_reasons_why_i_am_rejecting_the_application
    check 'rejection-reasons-selected-reasons-qualifications-field'
    check 'rejection-reasons-qualifications-selected-reasons-no-maths-gcse-field'
    check 'rejection-reasons-qualifications-selected-reasons-unverified-qualifications-field'
    fill_in 'rejection-reasons-unverified-qualifications-details-field', with: 'We can find no evidence of your GCSEs'

    check 'rejection-reasons-selected-reasons-personal-statement-field'
    check 'rejection-reasons-personal-statement-selected-reasons-quality-of-writing-field'
    fill_in 'rejection-reasons-quality-of-writing-details-field', with: 'We do not accept applications written in morse code'
    check 'rejection-reasons-personal-statement-selected-reasons-personal-statement-other-field'
    fill_in 'rejection-reasons-personal-statement-other-details-field', with: 'This was wayyyyy too personal'

    check 'rejection-reasons-selected-reasons-course-full-field'
    check 'rejection-reasons-selected-reasons-other-field'
    fill_in 'rejection-reasons-other-details-field', with: 'There are so many other reasons why your application was rejected...'

    click_button t('continue')
  end

  def and_the_cancellation_of_interviews_message_is_shown
    expect(page).to have_content('The upcoming interview will be cancelled.')
  end

  def and_i_submit_the_reasons_for_rejection
    click_button 'Reject application'
  end

  def and_the_interview_is_cancelled
    expect(@interview.reload.cancelled_at).not_to be_nil
  end
end
