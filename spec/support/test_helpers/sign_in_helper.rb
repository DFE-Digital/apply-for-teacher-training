module SignInHelper
  def given_i_am_signed_in
    @current_candidate ||= create(:candidate)
    login_as(@current_candidate)
  end

  def and_i_go_to_sign_in(candidate:)
    visit root_path
    choose 'Yes, sign in'
    fill_in 'Email', with: candidate.email_address
    click_link_or_button t('continue')

    open_email(candidate.email_address)
    click_magic_link_in_email
    confirm_sign_in
    login_as(candidate) # Make sure is logged in from warden
  end

  def click_magic_link_in_email
    current_email.find_css('a').first.click
  end

  def confirm_sign_in
    expect(page).to have_content 'Sign in'
    click_link_or_button 'Sign in'
  end

  def confirm_create_account
    expect(page).to have_content 'Create an account to apply for teacher training'
    click_link_or_button 'Create account'
  end
end
