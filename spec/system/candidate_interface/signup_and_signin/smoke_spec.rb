require 'rails_helper'

RSpec.feature 'Smoke test', smoke_test: true do
  it 'allows new account creation' do
    given_i_am_on_the_homepage
    when_i_choose_to_create_an_account
    then_i_can_create_an_account

    when_i_type_in_my_email_address
    and_i_click_continue
    then_i_am_told_to_check_my_email

    when_i_click_the_link_in_my_email
    and_i_create_an_account
    then_i_should_be_signed_in_successfully
  end

  def given_i_am_on_the_homepage
    visit '/'
  end

  def when_i_choose_to_create_an_account
    choose 'No, I need to create an account'
    click_on 'Continue'
  end

  def then_i_can_create_an_account
    expect(page).to have_content('Create an account')
  end

  def when_i_type_in_my_email_address
    fill_in 'Email address', with: 'test@example.com'
  end

  def and_i_click_continue
    click_on 'Continue'
  end

  def then_i_am_told_to_check_my_email
    expect(page).to have_content('Check your email')
  end

  def when_i_click_the_link_in_my_email
    visit extract_links_from_email(last_email).first
  end

  def and_i_create_an_account
    click_on 'Create account'
  end

  def then_i_should_be_signed_in_successfully
    expect(page).to have_content('Sign out')
  end
end
