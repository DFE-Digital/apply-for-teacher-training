require 'rails_helper'

RSpec.feature 'Feature flags' do
  include DfESignInHelpers

  scenario 'Manage features' do
    given_i_am_a_support_user
    and_there_is_a_feature_flag_set_up

    when_i_visit_the_features_page
    then_i_should_see_the_existing_feature_flags

    when_i_activate_the_feature
    then_the_feature_is_activated

    when_i_deactivate_the_feature
    then_the_feature_is_deactivated
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
    expect(page).to have_content 'Pilot open Inactive'
  end

  def when_i_activate_the_feature
    click_button 'Activate ‘Pilot open’'
  end

  def then_the_feature_is_activated
    expect(page).to have_content 'Pilot open Active'
    expect(FeatureFlag.active?('pilot_open')).to be true
  end

  def when_i_deactivate_the_feature
    click_button 'Deactivate ‘Pilot open’'
  end

  def then_the_feature_is_deactivated
    expect(page).to have_content 'Pilot open Inactive'
    expect(FeatureFlag.active?('pilot_open')).to be false
  end
end
