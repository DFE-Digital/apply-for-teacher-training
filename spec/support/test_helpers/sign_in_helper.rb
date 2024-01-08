module SignInHelper
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
