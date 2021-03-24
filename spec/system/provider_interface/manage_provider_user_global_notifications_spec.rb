require 'rails_helper'

RSpec.feature 'Managing global notifications' do
  include DfESignInHelpers

  scenario 'Provider can enable and disable global email notifications' do
    FeatureFlag.deactivate(:configurable_provider_notifications)

    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_sign_in_to_the_provider_interface

    when_i_go_to_my_account
    and_i_click_on_the_notification_settings_link

    when_i_choose_to_receive_notifications
    then_i_update_my_notification_preferences

    when_i_choose_not_to_receive_notifications
    then_i_update_my_notification_preferences
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_user_exists_in_apply_database(send_notifications: false)
  end

  def when_i_go_to_my_account
    click_on t('page_titles.provider.account')
  end

  def and_i_click_on_the_notification_settings_link
    click_on(t('page_titles.provider.notifications'))
  end

  def when_i_choose_to_receive_notifications
    choose 'On'
    click_on 'Save settings'
  end

  def then_i_update_my_notification_preferences
    expect(page).to have_content 'Email notification settings saved'
  end

  def when_i_choose_not_to_receive_notifications
    choose 'Off'
    click_on 'Save settings'
  end
end
