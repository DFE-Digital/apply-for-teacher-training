require 'rails_helper'

RSpec.feature 'Provider responds to application' do
  include CourseOptionHelpers
  include DfESignInHelpers
  include ProviderUserPermissionsHelper
  include ProviderRelationshipPermissionsHelper

  let(:course_option) { course_option_for_provider_code(provider_code: 'ABC') }

  let(:application_awaiting_provider_decision) do
    create(:submitted_application_choice, status: 'awaiting_provider_decision', course_option: course_option)
  end

  let(:application_rejected) do
    create(:submitted_application_choice, status: 'rejected', rejected_at: Time.zone.now, course_option: course_option)
  end

  scenario 'Provider cannot respond to an application if user lacks make_decisions' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_i_am_not_permitted_to_make_decisions_for_my_provider
    and_my_organisation_is_permitted_to_make_decisions
    and_i_sign_in_to_the_provider_interface

    when_i_try_to_respond_to_an_application
    then_i_get_access_denied
  end

  scenario 'Provider cannot respond to an application if organisation lacks make_decisions' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_i_am_permitted_to_make_decisions_for_my_provider
    and_my_organisation_is_not_permitted_to_make_decisions
    and_i_sign_in_to_the_provider_interface

    when_i_try_to_respond_to_an_application
    then_i_get_access_denied
  end

  scenario 'Provider can respond to an application with all feature flags on' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_i_sign_in_to_the_provider_interface
    and_i_am_permitted_to_make_decisions_for_my_provider
    and_my_organisation_is_permitted_to_make_decisions

    when_i_visit_a_application_with_status_awaiting_provider_decision
    then_i_can_see_its_status application_awaiting_provider_decision
    and_i_can_respond_to_the_application

    when_i_click_to_respond_to_the_application
    then_i_am_given_the_option_to_make_an_offer
    and_i_am_given_the_option_to_reject_the_application
  end

  scenario 'Provider can respond to an application when user-level make_decisions flag on' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_i_sign_in_to_the_provider_interface
    and_i_am_permitted_to_make_decisions_for_my_provider

    when_i_visit_a_application_with_status_awaiting_provider_decision
    then_i_can_see_its_status application_awaiting_provider_decision
    and_i_can_respond_to_the_application

    when_i_click_to_respond_to_the_application
    then_i_am_given_the_option_to_make_an_offer
    and_i_am_given_the_option_to_reject_the_application
  end

  scenario 'Provider can respond to an application with feature flags off' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_i_sign_in_to_the_provider_interface

    when_i_visit_a_application_with_status_awaiting_provider_decision
    then_i_can_see_its_status application_awaiting_provider_decision
    and_i_can_respond_to_the_application

    when_i_click_to_respond_to_the_application
    then_i_am_given_the_option_to_make_an_offer
    and_i_am_given_the_option_to_reject_the_application
  end

  scenario 'Provider cannot respond to application currently rejected' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_i_am_permitted_to_make_decisions_for_my_provider
    and_i_sign_in_to_the_provider_interface

    when_i_visit_a_application_with_status_rejected
    then_i_can_see_its_status application_rejected
    and_i_cannot_respond_to_the_application
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

  def and_i_am_not_permitted_to_make_decisions_for_my_provider
    FeatureFlag.activate 'provider_make_decisions_restriction'
  end

  def and_my_organisation_is_permitted_to_make_decisions
    course = application_awaiting_provider_decision.offered_course
    ratifying_provider = course.accredited_provider || course.provider

    permit_provider_make_decisions!(
      training_provider: course.provider,
      ratifying_provider: ratifying_provider,
    )
  end

  def and_my_organisation_is_not_permitted_to_make_decisions
    FeatureFlag.activate 'enforce_provider_to_provider_permissions'
  end

  def when_i_try_to_respond_to_an_application
    visit provider_interface_application_choice_respond_path(
      application_awaiting_provider_decision.id,
    )
  end

  def when_i_visit_a_application_with_status_awaiting_provider_decision
    visit provider_interface_application_choice_path(
      application_awaiting_provider_decision.id,
    )
  end

  def when_i_visit_a_application_with_status_rejected
    visit provider_interface_application_choice_path(
      application_rejected.id,
    )
  end

  def then_i_get_access_denied
    expect(page).to have_content 'Access denied'
  end

  def then_i_can_see_its_status(application)
    if application.status == 'awaiting_provider_decision'
      expect(page).to have_content 'Submitted'
    elsif application.status == 'rejected'
      expect(page).to have_content 'Rejected'
    end
  end

  def and_i_can_respond_to_the_application
    expect(page).to have_content 'Respond to application'
  end

  def and_i_cannot_respond_to_the_application
    expect(page).not_to have_content 'Respond to application'
  end

  def when_i_click_to_respond_to_the_application
    click_on 'Respond to application'
  end

  def then_i_am_given_the_option_to_make_an_offer
    expect(page).to have_content 'Make an offer'
  end

  def and_i_am_given_the_option_to_reject_the_application
    expect(page).to have_content 'Reject application'
  end
end
