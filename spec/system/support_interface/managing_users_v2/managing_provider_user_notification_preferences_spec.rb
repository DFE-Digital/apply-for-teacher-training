require 'rails_helper'

RSpec.feature 'Managing provider user notification preferences' do
  include DfESignInHelpers
  include DsiAPIHelper

  scenario 'editing the settings' do
    FeatureFlag.activate(:new_provider_user_flow)

    given_dfe_signin_is_configured
    and_i_am_a_support_user
    and_a_provider_user_exist

    when_i_visit_the_support_console
    and_i_navigate_to_provider_users_page
    and_i_click_on_the_user
    and_i_click_the_change_link

    then_i_can_see_all_notifications_are_on_by_default

    when_i_update_all_notifications_to_be_off
    then_the_notification_preferences_are_updated
  end

  def given_dfe_signin_is_configured
    dsi_api_response(success: true)
  end

  def and_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_a_provider_user_exist
    @provider_user = create(:provider_user, :with_notifications_enabled)
  end

  def when_i_visit_the_support_console
    visit support_interface_path
  end

  def and_i_navigate_to_provider_users_page
    click_link 'Providers'
    click_link 'Provider users'
  end

  def and_i_click_on_the_user
    click_link @provider_user.full_name
  end

  def and_i_click_the_change_link
    click_on 'Change notifications'
  end

  def then_i_can_see_all_notifications_are_on_by_default
    ProviderUserNotificationPreferences::NOTIFICATION_PREFERENCES.each do |type|
      expect(find(:css, "#provider-user-notification-preferences-#{type.to_s.dasherize}-true-field")).to be_checked
    end
  end

  def when_i_update_all_notifications_to_be_off
    ProviderUserNotificationPreferences::NOTIFICATION_PREFERENCES.each do |type|
      choose "provider-user-notification-preferences-#{type.to_s.dasherize}-false-field"
    end
    click_on 'Save settings'
  end

  def then_the_notification_preferences_are_updated
    expect(page).to have_content 'Provider user notifications updated'
    expect(page).to have_content 'Application received – No'
    expect(page).to have_content 'Application withdrawn by candidate – No'
    expect(page).to have_content 'Application automatically rejected – No'
    expect(page).to have_content 'Offer accepted – No'
    expect(page).to have_content 'Offer declined – No'
  end
end
