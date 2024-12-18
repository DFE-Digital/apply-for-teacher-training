RSpec.describe 'Smoke test', :smoke, type: :feature do
  it 'allows new account creation' do
    when_i_go_to_the_account_creation_page

    if magic_link_signup?
      when_i_choose_to_create_an_account
      then_i_can_create_an_account

      when_i_type_in_my_email_address
      and_i_click_continue
      then_i_have_been_sent_an_email
    else
      and_i_click_continue
      then_i_am_redirected_to_one_login
    end
  end

  def magic_link_signup?
    page.has_content?('Do you already have an account?')
  end

  def when_i_go_to_the_account_creation_page
    visit '/candidate/account'
  end

  def when_i_choose_to_create_an_account
    page.find('label', text: 'No, I need to create an account').click
    click_link_or_button 'Continue'
  end

  def then_i_can_create_an_account
    expect(page).to have_content('Create an account')
  end

  def when_i_type_in_my_email_address
    fill_in 'Email address', with: ENV.fetch('CANDIDATE_TEST_EMAIL')
  end

  def and_i_click_continue
    click_link_or_button 'Continue'
  end

  def then_i_have_been_sent_an_email
    expect(page).to have_content('Check your email')
  end

  def then_i_am_redirected_to_one_login
    page.current_host == ENV.fetch('GOVUK_ONE_LOGIN_ISSUER_URL', '').chomp('/')
  end
end
