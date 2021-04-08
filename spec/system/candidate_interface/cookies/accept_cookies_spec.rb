require 'rails_helper'

RSpec.feature 'Cookie banner' do
  include ActionView::Helpers::DateHelper

  scenario 'Candidate accepts cookies' do
    given_i_am_on_the_start_page
    and_i_can_see_the_cookie_banner
    when_i_accept_cookies
    then_i_can_no_longer_see_the_cookie_banner
    and_i_can_see_that_cookies_have_been_accepted
    when_i_hide_the_cookies_confirmation_message
  end

  def given_i_am_on_the_start_page
    visit '/'
  end

  def and_i_can_see_the_cookie_banner
    expect(page).to have_content('Cookies on Apply for teacher training')
  end

  def when_i_accept_cookies
    click_on 'Accept analytics cookies'
  end

  def and_i_can_see_that_cookies_have_been_accepted
    expect(page).to have_content('You’ve accepted analytics cookies.')
  end

  def when_i_hide_the_cookies_confirmation_message
    click_on 'Hide this message'
  end

  def then_i_can_no_longer_see_the_cookie_banner
    expect(page).not_to have_content('Cookies on Apply for teacher training')
  end

  def then_i_can_no_longer_see_the_cookies_confirmation_message
    expect(page).not_to have_content('You’ve accepted analytics cookies.')
  end
end
