require 'rails_helper'

RSpec.feature 'Provider can view end-of-cycle comms' do
  include DfESignInHelpers
  include DsiAPIHelper

  scenario 'Provider can view end-of-cycle comms when feature flag is on' do
    when_feature_flag_is_on
    and_i_visit_the_provider_start_page
    then_i_see_a_link_to_the_end_of_cycle_comms_page

    when_i_click_the_link_to_the_end_of_cycle_comms_page
    then_i_see_the_end_of_cycle_comms_page

    when_feature_flag_is_off
    and_i_visit_the_provider_start_page
    then_i_dont_see_a_link_to_the_end_of_cycle_comms_page
  end

  def when_feature_flag_is_on
    FeatureFlag.activate(:getting_ready_for_next_cycle_banner)
  end

  def and_i_visit_the_provider_start_page
    visit provider_interface_path
  end

  def then_i_see_a_link_to_the_end_of_cycle_comms_page
    expect(page).to have_link 'Getting ready for the next cycle: dates for your diary and our plans for a smooth transition'
  end

  def when_i_click_the_link_to_the_end_of_cycle_comms_page
    click_link 'Getting ready for the next cycle: dates for your diary and our plans for a smooth transition'
  end

  def then_i_see_the_end_of_cycle_comms_page
    expect(page).to have_content 'Getting ready for the next cycle (2020 to 2021)'
  end

  def when_feature_flag_is_off
    FeatureFlag.deactivate(:getting_ready_for_next_cycle_banner)
  end

  def then_i_dont_see_a_link_to_the_end_of_cycle_comms_page
    expect(page).not_to have_link 'Getting ready for the next cycle: dates for your diary and our plans for a smooth transition'
  end
end
