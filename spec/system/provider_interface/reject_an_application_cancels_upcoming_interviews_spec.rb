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
    click_link_or_button 'Make decision'
  end

  def and_i_choose_to_reject_it
    choose 'Reject application'
    click_link_or_button t('continue')
  end

  def then_i_give_reasons_why_i_am_rejecting_the_application
    check 'provider-interface-rejections-wizard-selected-reasons-qualifications-field'
    check 'provider-interface-rejections-wizard-qualifications-selected-reasons-no-maths-gcse-field'
    check 'provider-interface-rejections-wizard-qualifications-selected-reasons-unverified-qualifications-field'
    fill_in 'provider-interface-rejections-wizard-unverified-qualifications-details-field', with: 'We can find no evidence of your GCSEs'

    check 'provider-interface-rejections-wizard-selected-reasons-personal-statement-field'
    check 'provider-interface-rejections-wizard-personal-statement-selected-reasons-quality-of-writing-field'
    fill_in 'provider-interface-rejections-wizard-quality-of-writing-details-field', with: 'We do not accept applications written in morse code'
    check 'provider-interface-rejections-wizard-personal-statement-selected-reasons-personal-statement-other-field'
    fill_in 'provider-interface-rejections-wizard-personal-statement-other-details-field', with: 'This was wayyyyy too personal'

    check 'provider-interface-rejections-wizard-visa-sponsorship-selected-reasons-visa-sponsorship-not-supported-field'
    fill_in 'provider-interface-rejections-wizard-visa-sponsorship-not-supported-details-field', with: 'visa not supported'
    check 'provider-interface-rejections-wizard-visa-sponsorship-selected-reasons-visa-sponsorship-course-closed-field'
    fill_in 'provider-interface-rejections-wizard-visa-sponsorship-course-closed-details-field', with: 'visa course closed'

    check 'provider-interface-rejections-wizard-selected-reasons-course-full-field'
    check 'provider-interface-rejections-wizard-course-full-selected-reasons-salary-course-full-field'
    fill_in 'provider-interface-rejections-wizard-salary-course-full-details-field', with: 'Course is full'

    check 'provider-interface-rejections-wizard-course-full-selected-reasons-salary-course-full-field'
    fill_in 'provider-interface-rejections-wizard-salary-course-full-details-field', with: 'Course is full'

    check 'provider-interface-rejections-wizard-course-full-selected-reasons-course-full-other-field'
    fill_in 'provider-interface-rejections-wizard-course-full-other-details-field', with: 'Other course full'

    check 'provider-interface-rejections-wizard-selected-reasons-other-field'
    fill_in 'provider-interface-rejections-wizard-other-details-field', with: 'There are so many other reasons why your application was rejected...'

    click_link_or_button t('continue')
  end

  def and_the_cancellation_of_interviews_message_is_shown
    expect(page).to have_content('The upcoming interview will be cancelled.')
  end

  def and_i_submit_the_reasons_for_rejection
    click_link_or_button 'Reject application'
  end

  def and_the_interview_is_cancelled
    expect(@interview.reload.cancelled_at).not_to be_nil
  end
end
