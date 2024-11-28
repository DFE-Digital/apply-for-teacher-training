RSpec.describe 'Smoke test', :smoke, type: :feature do
  xit 'allows new account creation' do
    when_i_go_to_the_account_creation_page
    when_i_choose_to_create_an_account
    then_i_can_create_an_account

    when_i_type_in_my_email_address
    and_i_click_continue
    then_i_have_been_sent_an_email
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
end
