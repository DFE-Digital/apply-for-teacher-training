require 'rails_helper'

RSpec.feature 'Provider can view information in the banner' do
  include DfESignInHelpers
  include DsiAPIHelper

  scenario 'Provider can view changes to working days info when feature flag is on' do
    when_feature_flag_is_on
    and_i_visit_the_provider_start_page
    then_i_see_information_about_working_days_changes

    when_feature_flag_is_off
    and_i_visit_the_provider_start_page
    then_i_dont_see_information_about_working_days_changes
  end

  def when_feature_flag_is_on
    FeatureFlag.activate(:provider_information_banner)
  end

  def and_i_visit_the_provider_start_page
    visit provider_interface_path
  end

  def then_i_see_information_about_working_days_changes
    expect(page).to have_content 'The Manage service will be unavailable on Thursday 6th May from 8am to 9am'
  end

  def when_feature_flag_is_off
    FeatureFlag.deactivate(:provider_information_banner)
  end

  def then_i_dont_see_information_about_working_days_changes
    expect(page).not_to have_content 'The Manage service will be unavailable on Thursday 6th May from 8am to 9am'
  end
end
