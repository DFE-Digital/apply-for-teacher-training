require 'rails_helper'

RSpec.feature 'Managing notifications' do
  include DfESignInHelpers

  before { FeatureFlag.deactivate(:account_and_org_settings_changes) }

  scenario 'Provider can enable and disable individaul email notifications' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_sign_in_to_the_provider_interface

    when_i_go_to_my_account
    and_i_click_on_the_notification_settings_link
    then_i_can_see_all_notifications_are_on_by_default

    when_i_choose_not_to_receive_notifications
    then_my_notification_preferences_are_updated
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_user_exists_in_apply_database
  end

  def when_i_go_to_my_account
    click_on t('page_titles.provider.account')
  end

  def and_i_click_on_the_notification_settings_link
    click_on(t('page_titles.provider.notifications'))
  end

  def then_i_can_see_all_notifications_are_on_by_default
    ProviderUserNotificationPreferences::NOTIFICATION_PREFERENCES.each do |type|
      expect(find(:css, "#provider-user-notification-preferences-#{type.to_s.dasherize}-true-field")).to be_checked
    end
  end

  def when_i_choose_not_to_receive_notifications
    ProviderUserNotificationPreferences::NOTIFICATION_PREFERENCES.each do |type|
      choose "provider-user-notification-preferences-#{type.to_s.dasherize}-false-field"
    end
    click_on 'Save settings'
  end

  def then_my_notification_preferences_are_updated
    expect(page).to have_content 'Email notification settings saved'

    ProviderUserNotificationPreferences::NOTIFICATION_PREFERENCES.each do |type|
      expect(find(:css, "#provider-user-notification-preferences-#{type.to_s.dasherize}-false-field")).to be_checked
    end
  end
end
