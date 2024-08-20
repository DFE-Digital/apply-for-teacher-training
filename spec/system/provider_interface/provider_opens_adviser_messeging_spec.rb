require 'rails_helper'

RSpec.describe 'Provider opens adviser messaging', :js, skip: 'Intermittently failing' do
  scenario 'Speak to adviser' do
    given_the_chat_flag_is_active
    given_i_land_on_the_provider_page
    when_i_click_speak_to_adviser
    then_i_see_the_messaging_widget
  end

private

  def given_i_land_on_the_provider_page
    visit provider_interface_path
  end

  def when_i_click_speak_to_adviser
    click_on 'Speak to an adviser now'
  end

  def given_the_chat_flag_is_active
    FeatureFlag.activate('enable_chat_support')
  end

  def then_i_see_the_messaging_widget
    expect(page).to have_css("iframe[title='Messaging window']", wait: 3)
  end
end
