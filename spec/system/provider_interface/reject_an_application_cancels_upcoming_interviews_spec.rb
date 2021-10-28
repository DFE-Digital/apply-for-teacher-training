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
    @application_choice = create(:application_choice, :awaiting_provider_decision, course_option: course_option)
    @interview = create(:interview, application_choice: @application_choice, date_and_time: 2.days.from_now)
  end

  def when_i_respond_to_an_application
    visit provider_interface_application_choice_path(@application_choice)
    click_on 'Make decision'
  end

  def and_i_choose_to_reject_it
    choose 'Reject application'
    click_on t('continue')
  end

  def then_i_give_reasons_why_i_am_rejecting_the_application
    expect(page).to have_link('Back', href: new_provider_interface_application_choice_decision_path(@application_choice))

    choose 'reasons-for-rejection-candidate-behaviour-y-n-no-field'

    choose 'reasons-for-rejection-quality-of-application-y-n-no-field'

    choose 'reasons-for-rejection-qualifications-y-n-yes-field'
    check 'reasons-for-rejection-qualifications-which-qualifications-no-maths-gcse-field'
    check 'reasons-for-rejection-qualifications-which-qualifications-no-degree-field'

    choose 'reasons-for-rejection-performance-at-interview-y-n-no-field'

    choose 'reasons-for-rejection-course-full-y-n-no-field'

    choose 'reasons-for-rejection-offered-on-another-course-y-n-no-field'

    choose 'reasons-for-rejection-honesty-and-professionalism-y-n-yes-field'
    check 'reasons-for-rejection-honesty-and-professionalism-concerns-information-false-or-inaccurate-field'
    fill_in 'reasons-for-rejection-honesty-and-professionalism-concerns-information-false-or-inaccurate-details-field', with: 'We doubt claims about your golf handicap'
    check 'reasons-for-rejection-honesty-and-professionalism-concerns-references-field'
    fill_in 'reasons-for-rejection-honesty-and-professionalism-concerns-references-details-field', with: 'We cannot accept references from your mum'

    choose 'reasons-for-rejection-safeguarding-y-n-yes-field'
    check 'reasons-for-rejection-safeguarding-concerns-vetting-disclosed-information-field'
    fill_in 'reasons-for-rejection-safeguarding-concerns-vetting-disclosed-information-details-field', with: 'You abducted Jenny, now Matrix is coming to find her'

    choose 'reasons-for-rejection-cannot-sponsor-visa-y-n-no-field'

    click_on t('continue')
  end

  def and_the_cancellation_of_interviews_message_is_shown
    expect(page).to have_content('The upcoming interview will be cancelled.')
  end

  def and_i_submit_the_reasons_for_rejection
    click_on 'Send feedback and reject application'
  end

  def and_the_interview_is_cancelled
    expect(@interview.reload.cancelled_at).not_to be nil
  end
end
