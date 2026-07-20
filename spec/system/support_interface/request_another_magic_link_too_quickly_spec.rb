require 'rails_helper'

RSpec.describe 'A support user requests another magic link too quickly' do
  include DfESignInHelpers

  scenario 'signs in by requesting a new token too quickly' do
    FeatureFlag.activate('dfe_sign_in_fallback')

    given_i_am_registered_as_a_support_user
    when_i_visit_the_support_interface
    and_i_provide_my_email_address
    then_i_see_i_have_received_an_email

    when_i_click_back_and_go_to_sign_up_again
    then_i_see_that_an_email_has_already_been_sent
  end

private

  def given_i_am_registered_as_a_support_user
    @email = 'support@example.com'
    @support_user = create(:support_user, email_address: @email, dfe_sign_in_uid: 'DFE_SIGN_IN_UID', first_name: 'Michael')
  end

  def when_i_visit_the_support_interface
    visit support_interface_sign_in_path
  end

  def and_i_provide_my_email_address
    fill_in 'Email address', with: 'sUpPoRt@example.com '
    click_link_or_button t('continue')
  end

  def then_i_see_i_have_received_an_email
    expect(page).to have_element(:h1, text: 'Check your email', class: 'govuk-heading-l')
    expect(page).to have_element(
      :p,
      text: 'Sign in by clicking the link in the email you have been sent.',
      class: 'govuk-body-l',
    )
    expect(page).to have_element(
      :p,
      text: 'Check your spam and trash folder if you cannot find the email. You can also request another link to sign in.',
      class: 'govuk-body',
    )
  end

  def when_i_click_back_and_go_to_sign_up_again
    when_i_visit_the_support_interface
    and_i_provide_my_email_address
  end

  def then_i_see_that_an_email_has_already_been_sent
    expect(page).to have_element(:h1, text: 'We have already sent you an email to sign in', class: 'govuk-heading-l')
    expect(page).to have_element(
      :p,
      text: 'We sent an email with a link to sign in less than a minute ago. Follow the link to sign in.',
      class: 'govuk-body',
    )
    expect(page).to have_element(
      :p,
      text: 'If you have not received the email, wait 1 minute and try again.',
      class: 'govuk-body',
    )
  end
end
