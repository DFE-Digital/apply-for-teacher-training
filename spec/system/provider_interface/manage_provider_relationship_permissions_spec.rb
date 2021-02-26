require 'rails_helper'

RSpec.feature 'Managing provider to provider relationship permissions' do
  include DfESignInHelpers

  scenario 'Provider manages permissions for their organisation' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_sign_in_to_the_provider_interface
    and_i_can_manage_organisations_for_a_provider
    and_the_provider_has_courses_ratified_by_another_provider
    and_i_am_permitted_to_view_safeguarding_information
    and_the_provider_has_an_open_application_with_safeguarding_issues_declared

    when_i_view_the_application
    then_i_should_not_see_the_safeguarding_declaration_details

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

    when_i_visit_the_edit_provider_relationship_permissions_page
    and_i_allow_my_training_provider_to_view_diversity_information

    then_i_can_see_the_permissions_were_successfully_changed
    and_i_can_see_the_training_provider_has_permission_to_view_diversity
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_user_exists_in_apply_database
  end

  def and_i_can_manage_organisations_for_a_provider
    @provider_user = ProviderUser.last
    @provider_user.provider_permissions.update_all(manage_organisations: true)
    @training_provider = Provider.find_by(code: 'ABC')
    @ratifying_provider = build(:provider)
  end

  def and_i_am_permitted_to_view_safeguarding_information
    @provider_user.provider_permissions.update_all(view_safeguarding_information: true)
  end

  def and_the_provider_has_courses_ratified_by_another_provider
    @permissions = create(
      :provider_relationship_permissions,
      ratifying_provider: @ratifying_provider,
      training_provider: @training_provider,
      ratifying_provider_can_view_safeguarding_information: true,
      training_provider_can_view_safeguarding_information: false,
      setup_at: Time.zone.now,
    )
  end

  def and_the_provider_has_an_open_application_with_safeguarding_issues_declared
    @application_form = build(
      :application_form,
      safeguarding_issues: 'I have a criminal conviction.',
      safeguarding_issues_status: 'has_safeguarding_issues_to_declare',
    )
    @application_choice = create(
      :application_choice,
      status: :unsubmitted,
      course_option: build(
        :course_option,
        course: build(:course, accredited_provider: @ratifying_provider, provider: @training_provider),
      ),
      reject_by_default_at: 20.days.from_now,
      application_form: @application_form,
    )

    ApplicationStateChange.new(@application_choice).send_to_provider!
  end

  def when_i_view_the_application
    visit provider_interface_application_choice_path(@application_choice)
  end

  def then_i_should_not_see_the_safeguarding_declaration_details
    expect(page).not_to have_content('View information disclosed by the candidate')
  end

  def when_i_visit_the_edit_provider_relationship_permissions_page
    visit provider_interface_edit_provider_relationship_permissions_path(@permissions)
  end

  def and_i_allow_my_training_provider_to_view_safeguarding_information
    expect(page).to have_content('Which organisations can view safeguarding information?')

    within('.view-safeguarding-information') do
      check @training_provider.name
    end

    click_on 'Save permissions'
  end

  def then_i_can_see_the_permissions_were_successfully_changed
    expect(page).to have_content('Organisation permissions successfully updated')
  end

  def and_i_can_see_the_training_provider_has_permission_to_view_safeguarding
    expect(page).to have_content('Who can view safeguarding information?')

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
    expect(page).to have_content('Select which organisations can view safeguarding information')
  end

  def and_i_allow_my_training_provider_to_view_diversity_information
    expect(page).to have_content('Which organisations can view diversity information?')

    within('.view-diversity-information') do
      check @training_provider.name
    end

    click_on 'Save permissions'
  end

  def and_i_can_see_the_training_provider_has_permission_to_view_diversity
    expect(page).to have_content('Who can view diversity information?')

    within(find('.view-diversity-information', match: :first)) do
      expect(page).to have_content @training_provider.name
    end
  end
end
