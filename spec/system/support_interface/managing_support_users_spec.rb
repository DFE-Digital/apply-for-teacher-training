require 'rails_helper'

RSpec.feature 'Managing support users' do
  scenario 'creating a new support user' do
    given_i_am_a_support_user
    and_a_support_user_exists_in_the_database

    when_i_visit_the_support_console
    and_i_click_the_manange_support_users_link

    then_i_should_see_the_list_of_support_users
  end

  def given_i_am_a_support_user
    page.driver.browser.authorize('test', 'test')
  end

  def and_a_support_user_exists_in_the_database
    create(:support_user, email_address: 'person@education.gov.uk')
  end

  def when_i_visit_the_support_console
    visit '/support'
  end

  def and_i_click_the_manange_support_users_link
    click_link 'Support users'
  end

  def then_i_should_see_the_list_of_support_users
    expect(page).to have_content('Support users')
  end
end
