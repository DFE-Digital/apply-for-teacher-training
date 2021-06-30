require 'rails_helper'

RSpec.describe "withdrawing an application at the candidate's request", type: :feature do
  include DfESignInHelpers
  include CourseOptionHelpers

  scenario 'A provider user withdraws an application at the request of a candidate' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_the_withdraw_at_candidates_request_feature_flag_is_enabled
    and_i_am_permitted_to_make_decisions_for_my_provider
    and_my_organisation_has_received_an_application
    and_i_sign_in_to_the_provider_interface
    when_i_visit_a_submitted_application
    and_i_click_a_link_to_withdraw_at_candidates_request
    and_i_confirm_the_withdrawal
    then_i_see_a_message_confirming_that_the_application_has_been_withdrawn
    and_i_can_no_longer_see_the_withdraw_at_candidates_request_link
    and_the_candidate_receives_an_email_about_the_withdrawal
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_the_withdraw_at_candidates_request_feature_flag_is_enabled
    FeatureFlag.activate(:withdraw_at_candidates_request)
  end

  def and_i_am_permitted_to_make_decisions_for_my_provider
    @provider = create(:provider, :with_signed_agreement)
    @provider_user = create(:provider_user, :with_make_decisions, providers: [@provider], dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
  end

  def and_my_organisation_has_received_an_application
    course_option = course_option_for_provider_code(provider_code: @provider.code)
    @application_choice = create(:submitted_application_choice, :with_completed_application_form, course_option: course_option)
  end

  def and_i_sign_in_to_the_provider_interface
    provider_signs_in_using_dfe_sign_in
  end

  def when_i_visit_a_submitted_application
    visit provider_interface_application_choice_path(@application_choice)
  end

  def and_i_click_a_link_to_withdraw_at_candidates_request
    click_on "Withdraw at candidate's request"
  end

  def and_i_confirm_the_withdrawal
    expect(page).to have_content('Confirm that the candidate wants to withdraw their application')

    click_on 'Withdraw application'
  end

  def then_i_see_a_message_confirming_that_the_application_has_been_withdrawn
    expect(page).to have_current_path(provider_interface_application_choice_path(@application_choice))
    expect(page).to have_content('Application withdrawn')
  end

  def and_i_can_no_longer_see_the_withdraw_at_candidates_request_link
    expect(page).not_to have_link "Withdraw at candidate's request"
  end

  def and_the_candidate_receives_an_email_about_the_withdrawal
    open_email(@application_choice.application_form.candidate.email_address)
    expect(current_email.subject).to have_content 'Update on your application - all decisions now made'
  end
end
