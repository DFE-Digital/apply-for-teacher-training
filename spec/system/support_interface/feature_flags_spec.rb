require 'rails_helper'

RSpec.feature 'Feature flags', with_audited: true do
  include DfESignInHelpers

  scenario 'Manage features' do
    given_i_am_a_support_user
    and_there_is_a_feature_flag_set_up

    when_i_visit_the_features_page
    then_i_should_see_the_existing_feature_flags

    when_i_activate_the_feature
    then_the_feature_is_activated
    and_i_can_see_the_activation_in_the_audit_trail
    and_a_slack_notification_about_the_activation_is_sent

    when_i_deactivate_the_feature
    then_the_feature_is_deactivated
    and_i_can_see_the_deactivation_in_the_audit_trail
    and_a_slack_notification_about_the_deactivation_is_sent
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_a_feature_flag_set_up
    FeatureFlag.deactivate('pilot_open')
  end

  def when_i_visit_the_features_page
    visit support_interface_feature_flags_path
  end

  def then_i_should_see_the_existing_feature_flags
    within('.app-summary-card', text: 'Pilot open') do
      expect(page).to have_content('Pilot open')
      expect(page).to have_content(pilot_open_feature.owner)
      expect(page).to have_content(pilot_open_feature.description)
      expect(page).to have_content('Temporary')
    end
  end

  def when_i_activate_the_feature
    within(pilot_open_summary_card) { click_link 'Confirm environment to make changes' }
    fill_in 'Type ‘test’ to confirm that you want to proceed', with: 'test'
    click_button 'Continue'

    within(pilot_open_summary_card) { click_button 'Activate' }
  end

  def then_the_feature_is_activated
    expect(page).to have_content('Active')
    expect(FeatureFlag.active?('pilot_open')).to be true
  end

  def and_i_can_see_the_activation_in_the_audit_trail
    expect(page).to have_content('Changed to active by user@apply-support.com')
  end

  def and_a_slack_notification_about_the_activation_is_sent
    expect_slack_message_with_text(':flags: Feature ‘Pilot open‘ was activated')
  end

  def when_i_deactivate_the_feature
    within(pilot_open_summary_card) { click_button 'Deactivate' }
  end

  def then_the_feature_is_deactivated
    expect(page).to have_content('Inactive')
    expect(FeatureFlag.active?('pilot_open')).to be false
  end

  def and_i_can_see_the_deactivation_in_the_audit_trail
    expect(page).to have_content('Changed to inactive by user@apply-support.com')
  end

  def and_a_slack_notification_about_the_deactivation_is_sent
    expect_slack_message_with_text(':flags: Feature ‘Pilot open‘ was deactivated')
  end

  def pilot_open_summary_card
    find('.app-summary-card', text: 'Pilot open')
  end

  def pilot_open_feature
    @pilot_open_feature ||= FeatureFlag::FEATURES[:pilot_open]
  end
end
