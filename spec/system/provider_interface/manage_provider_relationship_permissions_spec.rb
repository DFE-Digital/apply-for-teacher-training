require 'rails_helper'

RSpec.feature 'Managing provider to provider relationship permissions' do
  include DfESignInHelpers

  scenario 'Provider manages permissions for their organisation' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_the_provider_permissions_feature_is_enabled
    and_the_safeguarding_declaration_feature_flag_is_active
    and_i_sign_in_to_the_provider_interface
    and_i_can_manage_organisations_for_a_provider
    and_the_provider_has_courses_ratified_by_another_provider
    and_i_am_permitted_to_view_safeguarding_information
    and_the_provider_has_an_open_application

    when_i_view_the_application
    then_i_should_not_see_the_safeguarding_declaration_section

    when_i_visit_the_edit_provider_relationship_permissions_page
    and_i_allow_my_training_provider_to_view_safeguarding_information

    then_i_can_see_the_permissions_were_successfully_changed
    and_i_can_see_the_training_provider_has_permission_to_view_safeguarding

    when_i_view_the_application
    then_i_should_see_the_safeguarding_declaration_section

    when_i_visit_the_edit_provider_relationship_permissions_page
    and_i_deny_my_training_provider_permission_to_view_safeguarding_information

    then_i_can_see_the_permissions_were_successfully_changed
    and_i_can_see_the_ratifying_provider_has_permission_to_view_safeguarding

    when_i_visit_the_edit_provider_relationship_permissions_page
    and_i_remove_safeguarding_permissions_from_all_providers_and_attempt_to_save
    then_i_can_see_a_validation_error_telling_me_to_assign_an_org_to_a_permission
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_user_exists_in_apply_database
  end

  def and_the_provider_permissions_feature_is_enabled
    FeatureFlag.activate('enforce_provider_to_provider_permissions')
  end

  def and_the_safeguarding_declaration_feature_flag_is_active
    FeatureFlag.activate('provider_view_safeguarding')
  end

  def and_i_can_manage_organisations_for_a_provider
    @provider_user = ProviderUser.last
    @provider_user.provider_permissions.update_all(manage_organisations: true)
    @training_provider = Provider.find_by(code: 'ABC')
    @ratifying_provider = create(:provider)
  end

  def and_i_am_permitted_to_view_safeguarding_information
    @provider_user.provider_permissions.update_all(view_safeguarding_information: true)
  end

  def and_the_provider_has_courses_ratified_by_another_provider
    create(
      :provider_relationship_permissions,
      ratifying_provider: @ratifying_provider,
      training_provider: @training_provider,
      ratifying_provider_can_view_safeguarding_information: true,
      training_provider_can_view_safeguarding_information: false,
      setup_at: Time.zone.now,
    )
  end

  def and_the_provider_has_an_open_application
    @application_choice = create(
      :application_choice,
      status: :application_complete,
      course_option: create(
        :course_option,
        course: create(:course, accredited_provider_id: @ratifying_provider.id, provider_id: @training_provider.id),
      ),
      reject_by_default_at: 20.days.from_now,
      application_form: create(:application_form),
    )

    ApplicationStateChange.new(@application_choice).send_to_provider!
  end

  def when_i_view_the_application
    visit provider_interface_application_choice_path(@application_choice)
  end

  def then_i_should_not_see_the_safeguarding_declaration_section
    expect(page).not_to have_content('Criminal convictions and professional misconduct')
  end

  def when_i_visit_the_edit_provider_relationship_permissions_page
    visit provider_interface_edit_provider_relationship_permissions_path(
      ratifying_provider_id: @ratifying_provider.id,
      training_provider_id: @training_provider.id,
    )
  end

  def and_i_allow_my_training_provider_to_view_safeguarding_information
    expect(page).to have_content('Which organisations can see safeguarding information?')

    within('.view-safeguarding-information') do
      check @training_provider.name
    end

    click_on 'Save permissions'
  end

  def then_i_can_see_the_permissions_were_successfully_changed
    expect(page).to have_content('Permissions successfully changed')
  end

  def and_i_can_see_the_training_provider_has_permission_to_view_safeguarding
    expect(page).to have_content('The following organisation(s) can see safeguarding information:')

    within(find('.view-safeguarding-information', match: :first)) do
      expect(page).to have_content @training_provider.name
      expect(page).to have_content @ratifying_provider.name
    end
  end

  def when_i_confirm_the_permissions
    click_on 'Save permissions'
  end

  def then_i_should_see_the_safeguarding_declaration_section
    expect(page).to have_content('Criminal convictions and professional misconduct')
  end

  def and_i_deny_my_training_provider_permission_to_view_safeguarding_information
    within(find('.view-safeguarding-information', match: :first)) do
      uncheck @training_provider.name
    end

    click_on 'Save permissions'
  end

  def and_i_can_see_the_ratifying_provider_has_permission_to_view_safeguarding
    within(find('.view-safeguarding-information', match: :first)) do
      expect(page).not_to have_content @training_provider.name
      expect(page).to have_content @ratifying_provider.name
    end
  end

  def and_i_remove_safeguarding_permissions_from_all_providers_and_attempt_to_save
    within(find('.view-safeguarding-information', match: :first)) { uncheck @ratifying_provider.name }
    click_on 'Save permissions'
  end

  def then_i_can_see_a_validation_error_telling_me_to_assign_an_org_to_a_permission
    expect(page).to have_content('At least one organisation must have permission to view safeguarding information')
  end
end
