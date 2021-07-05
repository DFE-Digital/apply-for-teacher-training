require 'rails_helper'

RSpec.feature 'Provider uses webchat' do
  include DfESignInHelpers

  scenario 'controlling the widget via a link in the footer', js: true do
    given_i_am_a_provider_user
    and_chat_support_is_enabled
    and_i_sign_in_to_the_provider_interface
    when_i_visit_the_provider_interface
    and_there_is_no_support_agent_online

    then_i_should_see_a_placeholder_in_the_footer

    when_a_support_agent_comes_online
    then_i_should_see_a_link_in_the_footer
    and_when_i_click_the_link_i_see_a_popup

    when_the_support_agent_goes_offline
    then_i_should_be_informed_chat_is_unavailable
  end

  def given_i_am_a_provider_user
    provider_user = create(:provider_user)
    user_exists_in_dfe_sign_in(email_address: provider_user.email_address)
  end

  def and_chat_support_is_enabled
    FeatureFlag.activate(:enable_chat_support)
  end

  def and_i_sign_in_to_the_provider_interface
    provider_signs_in_using_dfe_sign_in
  end

  def when_i_visit_the_provider_interface
    visit provider_interface_applications_path
  end

  def and_there_is_no_support_agent_online; end

  def then_i_should_see_a_placeholder_in_the_footer
    expect(page).to have_content('You cannot use online chat')
  end

  def when_a_support_agent_comes_online
    page.evaluate_script('setZendeskStatus("online")')
  end

  def then_i_should_see_a_link_in_the_footer
    expect(page).to have_content('Speak to an advisor now')
  end

  def and_when_i_click_the_link_i_see_a_popup
    click_link 'Speak to an advisor now'

    expect(page.evaluate_script('window.zendeskPopupOpen')).to eq true
  end

  def when_the_support_agent_goes_offline
    page.evaluate_script('setZendeskStatus("offline")')
  end

  def then_i_should_be_informed_chat_is_unavailable
    expect(page).to have_content('Available Monday to Friday')
  end
end
