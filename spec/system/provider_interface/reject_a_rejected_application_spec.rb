require 'rails_helper'

RSpec.describe 'Reject a rejected application' do
  include DfESignInHelpers
  include ProviderUserPermissionsHelper
  include CourseOptionHelpers

  scenario 'an application is rejected as I give reasons for rejection' do
    FeatureFlag.activate(:structured_reasons_for_rejection)

    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_i_am_permitted_to_make_decisions_on_applications_for_my_provider
    and_my_organisation_has_received_an_application
    and_i_sign_in_to_the_provider_interface

    when_i_choose_to_reject_an_application

    then_i_give_reasons_why_i_am_rejecting_the_application_and_check_them
    and_the_same_application_is_rejected_elsewhere
    and_i_submit_the_reasons_for_rejection
    then_i_can_see_an_error_message
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

  def and_my_organisation_has_received_an_application
    course_option = course_option_for_provider_code(provider_code: 'ABC')
    @application_choice = create(:application_choice, :awaiting_provider_decision, course_option: course_option)
  end

  def when_i_choose_to_reject_an_application
    visit provider_interface_application_choice_respond_path(@application_choice)

    choose 'Reject application'
    click_on 'Continue'
  end

  def then_i_give_reasons_why_i_am_rejecting_the_application_and_check_them
    choose 'reasons-for-rejection-candidate-behaviour-y-n-yes-field'
    check 'reasons-for-rejection-candidate-behaviour-what-did-the-candidate-do-other-field'
    fill_in 'reasons-for-rejection-candidate-behaviour-other-field', with: "There was no need to sing 'Run to the Hills' for us"
    fill_in 'reasons-for-rejection-candidate-behaviour-what-to-improve-field', with: 'Leave the singing out next time'

    choose 'reasons-for-rejection-quality-of-application-y-n-no-field'

    choose 'reasons-for-rejection-qualifications-y-n-no-field'

    choose 'reasons-for-rejection-performance-at-interview-y-n-no-field'

    choose 'reasons-for-rejection-course-full-y-n-no-field'

    choose 'reasons-for-rejection-offered-on-another-course-y-n-no-field'

    choose 'reasons-for-rejection-honesty-and-professionalism-y-n-yes-field'
    check 'reasons-for-rejection-honesty-and-professionalism-concerns-information-false-or-inaccurate-field'
    fill_in 'reasons-for-rejection-honesty-and-professionalism-concerns-information-false-or-inaccurate-details-field', with: 'We doubt claims about your golf handicap'

    choose 'reasons-for-rejection-safeguarding-y-n-no-field'

    click_on 'Continue'

    expect(page).to have_content('Something you did')
    expect(page).to have_content("There was no need to sing 'Run to the Hills' for us\nDetails: Leave the singing out next time")

    expect(page).to have_content('Honesty and professionalism')
    expect(page).to have_content('We doubt claims about your golf handicap')
  end

  def and_the_same_application_is_rejected_elsewhere
    another_user = ProviderUser.last
    permit_make_decisions!(dfe_sign_in_uid: another_user.dfe_sign_in_uid)

    RejectApplication.new(actor: another_user, application_choice: @application_choice, rejection_reason: 'Badbadbad').save
  end

  def and_i_submit_the_reasons_for_rejection
    click_on 'Reject application'
  end

  def then_i_can_see_an_error_message
    expect(page).to have_current_path(provider_interface_reasons_for_rejection_commit_path(@application_choice))
    expect(page).to have_content('There is a problem')
    expect(page).to have_content('The application is not ready for that action')
  end
end
