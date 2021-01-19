module SignInHelper
  def click_magic_link_in_email
    current_email.find_css('a').first.click
  end

  def confirm_sign_in
    expect(page).to have_content 'Confirm sign in'
    click_button t('continue')
  end
end
