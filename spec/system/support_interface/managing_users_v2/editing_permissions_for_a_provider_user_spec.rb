require 'rails_helper'

RSpec.feature 'Managing provider users v2' do
  include DfESignInHelpers
  include DsiAPIHelper

  scenario 'editing permissions for a provider user', with_audited: true do
    FeatureFlag.activate(:new_provider_user_flow)

    given_dfe_signin_is_configured
    and_i_am_a_support_user
    and_synced_providers_exist
    and_a_provider_user_exists_for_both_provider

    when_i_visit_the_first_provider_page
    and_i_click_on_users
    then_i_should_see_the_provider_user_listed

    when_i_click_update_permissions
    then_i_see_the_edit_permissions_form
    and_i_see_that_can_edit_permissions_for_both_providers

    when_i_check_permission_to_manage_users_for_the_first_provider
    and_i_check_permission_to_access_diversity_information_for_the_second_provider
    and_i_click_save_permissions
    then_i_can_see_the_provider_user_page
    then_i_should_see_the_provider_user_has_been_successfully_added
    and_the_provider_user_has_manage_user_permissions_for_the_first_provider
    and_access_diversity_info_permissions_for_the_second_provider
  end

  def given_dfe_signin_is_configured
    set_dsi_api_response(success: true)
  end

  def and_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_synced_providers_exist
    @provider_one = create(:provider, name: 'Example provider one', code: 'ABC', sync_courses: true)
    @provider_two = create(:provider, name: 'Example provider two', code: 'DEF', sync_courses: true)

    create(:course, :open_on_apply, provider: @provider_one)
    create(:course, :open_on_apply, provider: @provider_two)
  end

  def and_a_provider_user_exists_for_both_provider
    @provider_user = create(:provider_user, providers: [@provider_one, @provider_two])
  end

  def when_i_visit_the_first_provider_page
    visit support_interface_provider_path(@provider_one)
  end

  def and_i_click_on_users
    click_on 'Users'
  end

  def then_i_should_see_the_provider_user_listed
    expect(page).to have_content("#{@provider_user.first_name} #{@provider_user.last_name}")
  end

  def when_i_click_update_permissions
    click_on 'Update permissions'
  end

  def then_i_see_the_edit_permissions_form
    expect(page).to have_content("Change #{@provider_user.first_name} #{@provider_user.last_name}’s permissions")
  end

  def and_i_see_that_can_edit_permissions_for_both_providers
    expect(page).to have_content(@provider_one.name_and_code)
    expect(page).to have_content(@provider_two.name_and_code)
  end

  def when_i_check_permission_to_manage_users_for_the_first_provider
    within first('.govuk-checkboxes__item') do
      check 'Manage users'
    end
  end

  def and_i_check_permission_to_access_diversity_information_for_the_second_provider
    within all('.govuk-checkboxes__item').last do
      check 'Access diversity information'
    end
  end

  def and_i_click_save_permissions
    click_on 'Save permissions'
  end

  def then_i_can_see_the_provider_user_page
    expect(page).to have_content("#{@provider_user.first_name} #{@provider_user.last_name}")
  end

  def and_the_provider_user_has_manage_user_permissions_for_the_first_provider
    within permissions_summary_for_provider(@provider_one) do
      expect(page).to have_content('Manage users')
    end
  end

  def and_access_diversity_info_permissions_for_the_second_provider
    within permissions_summary_for_provider(@provider_two) do
      expect(page).to have_content('Access diversity information')
    end
  end

  def then_i_should_see_the_provider_user_has_been_successfully_added
    expect(page).to have_content("User #{@provider_user.first_name} #{@provider_user.last_name} updated")
  end

  def permissions_summary_for_provider(provider)
    "#provider-#{provider.id}-enabled-permissions"
  end
end
