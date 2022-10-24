RSpec.feature 'Smoke test', type: :feature, smoke: true do
  it 'allows new account creation' do
    given_i_am_on_the_homepage
    when_i_choose_to_create_an_account
    then_i_can_create_an_account

    when_i_type_in_my_email_address
    and_i_click_continue
    then_i_should_have_been_sent_an_email
  end

  def given_i_am_on_the_homepage
    visit '/'
  end

  def when_i_choose_to_create_an_account
    page.find('label', text: 'No, I need to create an account').click
    click_on 'Continue'
  end

  def then_i_can_create_an_account
    expect(page).to have_content('Create an account')
  end

  def when_i_type_in_my_email_address
    fill_in 'Email address', with: ENV.fetch('CANDIDATE_TEST_EMAIL')
  end

  def and_i_click_continue
    click_on 'Continue'
  end

  def then_i_should_have_been_sent_an_email
    expect(page).to have_content('Check your email')
  end
end
