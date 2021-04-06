require 'rails_helper'

RSpec.feature 'Provider cannot respond to application' do
  include CourseOptionHelpers
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  let(:training_provider) { Provider.find_by_code('ABC') }

  let(:ratified_course) do
    create(
      :course,
      :open_on_apply,
      provider: training_provider,
      accredited_provider: create(:provider),
    )
  end

  let(:course_option) { create(:course_option, course: ratified_course) }

  let(:application_awaiting_provider_decision) do
    create(:submitted_application_choice, status: 'awaiting_provider_decision', course_option: course_option)
  end

  scenario 'Provider cannot respond to an application they cannot make offer on' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_my_provider_relationship_permissions_have_been_set_up
    and_i_sign_in_to_the_provider_interface

    when_i_am_permitted_to_make_decisions_for_my_provider
    and_my_organisation_is_not_permitted_to_make_decisions
    and_i_try_to_respond_to_an_application
    then_i_get_access_denied

    when_i_am_not_permitted_to_make_decisions_for_my_provider
    and_my_organisation_is_permitted_to_make_decisions
    and_i_try_to_respond_to_an_application
    then_i_get_access_denied
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_for_my_provider
    provider_user_exists_in_apply_database
  end

  def when_i_am_permitted_to_make_decisions_for_my_provider
    permit_make_decisions!
  end

  def when_i_am_not_permitted_to_make_decisions_for_my_provider
    deny_make_decisions!
  end

  def and_my_provider_relationship_permissions_have_been_set_up
    course = application_awaiting_provider_decision.current_course
    ratifying_provider = course.accredited_provider

    @provider_relationship = create(
      :provider_relationship_permissions,
      training_provider: course.provider,
      ratifying_provider: ratifying_provider,
    )
  end

  def and_my_organisation_is_permitted_to_make_decisions
    @provider_relationship.update(
      training_provider_can_make_decisions: true,
    )
  end

  def and_my_organisation_is_not_permitted_to_make_decisions
    @provider_relationship.update(
      training_provider_can_make_decisions: false,
      ratifying_provider_can_make_decisions: true,
    )
  end

  def and_i_try_to_respond_to_an_application
    visit provider_interface_application_choice_respond_path(
      application_awaiting_provider_decision.id,
    )
  end

  def then_i_get_access_denied
    expect(page).to have_content 'Access denied'
  end
end
