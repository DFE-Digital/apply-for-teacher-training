require 'rails_helper'

RSpec.describe 'Feature flags', :with_audited do
  include DfESignInHelpers

  scenario 'Manage features' do
    given_i_am_a_support_user
    and_there_is_a_feature_flag_set_up

    when_i_visit_the_features_page
    then_i_see_the_existing_feature_flags

    when_i_activate_the_feature
    then_the_feature_is_activated
    and_i_can_see_the_activation_in_the_audit_trail

    when_i_deactivate_the_feature
    then_the_feature_is_deactivated
    and_i_can_see_the_deactivation_in_the_audit_trail
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_a_feature_flag_set_up
    FeatureFlag.deactivate('dfe_sign_in_fallback')
  end

  def when_i_visit_the_features_page
    visit support_interface_feature_flags_path
  end

  def then_i_see_the_existing_feature_flags
    within('.app-summary-card', text: 'DfE sign in fallback') do
      expect(page).to have_content('DfE sign in fallback')
      expect(page).to have_content(dfe_sign_in_fallback_feature.owner)
      expect(page).to have_content(dfe_sign_in_fallback_feature.description)
      expect(page).to have_content('Invariant')
    end
  end

  def when_i_activate_the_feature
    within(dfe_sign_in_fallback_summary_card) { click_link_or_button 'Confirm environment to make changes' }

    fill_in 'Type ‘test’ to confirm that you want to proceed', with: 'test'
    click_link_or_button 'Continue'

    within(dfe_sign_in_fallback_summary_card) { click_link_or_button 'Activate' }
  end

  def then_the_feature_is_activated
    expect(page).to have_content('Active')
    expect(FeatureFlag.active?('dfe_sign_in_fallback')).to be true
  end

  def and_i_can_see_the_activation_in_the_audit_trail
    expect(page).to have_content('Changed to active by user@apply-support.com')
  end

  def when_i_deactivate_the_feature
    within(dfe_sign_in_fallback_summary_card) { click_link_or_button 'Deactivate' }
  end

  def then_the_feature_is_deactivated
    expect(page).to have_content('Inactive')
    expect(FeatureFlag.active?('dfe_sign_in_fallback')).to be false
  end

  def and_i_can_see_the_deactivation_in_the_audit_trail
    expect(page).to have_content('Changed to inactive by user@apply-support.com')
  end

  def dfe_sign_in_fallback_summary_card
    find('.app-summary-card', text: 'DfE sign in fallback')
  end

  def dfe_sign_in_fallback_feature
    @dfe_sign_in_fallback_feature ||= FeatureFlag::FEATURES[:dfe_sign_in_fallback]
  end
end
