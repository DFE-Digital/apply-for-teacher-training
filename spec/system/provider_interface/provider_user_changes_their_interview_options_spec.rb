require 'rails_helper'

RSpec.describe 'Provider user changes their interview options', feature_flag: :interview_handling do
  include DfESignInHelpers

  let(:current_provider) { create(:provider) }

  scenario 'Provider user has permission to manage the organisation settings' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_sign_in_to_the_provider_interface
    and_i_have_permission_to_manage_organisation_permissions
    when_i_visit_the_organisation_settings
    then_i_see_a_link_to_interview_options

    when_i_click_on_interview_options
    then_i_see_the_interview_option_page
    and_the_interview_option_is_set_to_in_manage

    when_i_click_on_change
    then_i_see_the_interview_options_form

    when_i_select_arrange_interviews_outside_this_service
    and_i_click_on_save
    then_i_see_the_interview_option_page
    and_i_see_the_interview_option_has_been_successfully_changed
    and_the_interview_option_is_set_to_outside_service
  end

  scenario 'Provider user does not have permission to manage the organisation settings' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_sign_in_to_the_provider_interface
    when_i_visit_the_organisation_settings
    then_i_see_a_link_to_interview_options

    when_i_click_on_interview_options
    then_i_see_the_interview_option_page
    and_the_interview_option_is_set_to_in_manage
    and_i_can_not_see_the_change_link

    when_i_visit_the_interview_options_form
    then_i_see_my_access_is_denied
  end

private

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    @provider_user = provider_user_exists_in_apply_database(provider_code: current_provider.code)
  end

  def and_i_have_permission_to_manage_organisation_permissions
    permission = ProviderPermissions.find_or_create_by!(provider: current_provider, provider_user: @provider_user)
    permission.update!(manage_organisations: true)
  end

  def when_i_visit_the_organisation_settings
    visit provider_interface_organisation_settings_organisations_path
  end

  def then_i_see_a_link_to_interview_options
    expect(page).to have_link(
      'Interview options',
      href: provider_interface_organisation_settings_organisation_interview_options_path(organisation_id: current_provider.id),
    )
  end

  def when_i_click_on_interview_options
    click_on "Interview options #{current_provider.name}"
  end

  def then_i_see_the_interview_option_page
    expect(page).to have_current_path(
      provider_interface_organisation_settings_organisation_interview_options_path(organisation_id: current_provider.id),
    )
    expect(page).to have_element(:span, text: current_provider.name)
    expect(page).to have_element(:h1, text: 'Interview options')
  end

  def and_the_interview_option_is_set_to_in_manage
    within('.govuk-summary-list') do
      expect(page).to have_element(:dt, text: 'How do you want to handle interview details?', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: 'Record interview details in Manage', class: 'govuk-summary-list__value')
    end
  end

  def when_i_click_on_change
    click_on 'Change'
  end

  def then_i_see_the_interview_options_form
    expect(page).to have_current_path(
      provider_interface_organisation_settings_organisation_edit_interview_options_path(organisation_id: current_provider.id),
    )
    expect(page).to have_element(:h1, text: 'How do you want to handle interview details?', class: 'govuk-fieldset__heading')
    expect(page).to have_checked_field('Record interview details in Manage', type: :radio)
    expect(page).to have_field('Arrange interviews outside this service', type: :radio)
  end

  def when_i_select_arrange_interviews_outside_this_service
    choose 'Arrange interviews outside this service'
  end

  def and_i_click_on_save
    click_on 'Save'
  end

  def and_the_interview_option_is_set_to_outside_service
    within('.govuk-summary-list') do
      expect(page).to have_element(:dt, text: 'How do you want to handle interview details?', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: 'Arrange interviews outside this service', class: 'govuk-summary-list__value')
    end
  end

  def and_i_see_the_interview_option_has_been_successfully_changed
    expect(page).to have_element(:div, text: 'Interview options updated', class: 'govuk-notification-banner--success')
  end

  def and_i_can_not_see_the_change_link
    expect(page).to have_no_link(
      'Change',
      href: "/provider/organisation-settings/interview-options/organisations/#{current_provider.id}/edit",
    )
  end

  def when_i_visit_the_interview_options_form
    visit provider_interface_organisation_settings_organisation_edit_interview_options_path(organisation_id: current_provider.id)
  end

  def then_i_see_my_access_is_denied
    expect(page).to have_element(:h1, text: 'Access denied')
    expect(page).to have_element(:p, text: 'To perform this action you need permission to ‘manage_organisations’.')
  end
end
