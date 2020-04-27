require 'rails_helper'

RSpec.feature 'Candidate tries to sign up using magic link with an invalid token' do
  scenario 'Candidate signs in and receives an email inviting them to sign up' do
    given_the_pilot_is_open
    and_the_covid_19_feature_flag_is_active

    given_i_am_a_candidate_without_an_account

    when_i_go_to_sign_up
    and_i_fill_in_the_eligiblity_form_with_yes
    and_i_submit_my_email_address
    then_i_receive_an_email_inviting_me_to_sign_up
    and_a_slack_message_is_sent

    when_the_magic_link_token_is_overwritten
    and_i_click_on_the_link_in_my_email
    then_i_am_taken_to_the_expired_link_page

    when_i_click_the_button_to_send_me_a_sign_in_email
    then_i_receive_an_email_inviting_me_to_sign_in
    and_i_click_on_the_link_in_my_email
    then_i_see_the_before_you_start_page
    and_i_should_see_an_account_created_flash_message
    and_i_should_not_see_the_covid19_banner

    when_click_on_the_apply_for_teacher_training_link_in_the_header
    then_i_should_see_the_application_page
  end


  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def and_the_covid_19_feature_flag_is_active
    FeatureFlag.activate('covid_19')
  end

  def given_i_am_a_candidate_without_an_account
    @email = "#{SecureRandom.hex}@example.com"
  end

  def when_i_go_to_sign_up
    visit '/'
    click_on 'Start now'

    choose 'No, I need to create an account'
    click_button 'Continue'
  end

  def and_i_fill_in_the_eligiblity_form_with_yes
    within_fieldset('Are you a citizen of the UK or the EU?') do
      choose 'Yes'
    end

    within_fieldset('Did you gain all your qualifications at institutions based in the UK?') do
      choose 'Yes'
    end

    click_on 'Continue'
  end

  def and_i_submit_my_email_address
    fill_in t('authentication.sign_up.email_address.label'), with: @email
    check t('authentication.sign_up.accept_terms_checkbox')
    click_on t('authentication.sign_up.button_continue')
  end

  def then_i_receive_an_email_inviting_me_to_sign_up
    open_email(@email)
    expect(current_email.subject).to have_content t('authentication.sign_up.email.subject')
  end

  def and_a_slack_message_is_sent
    expect_slack_message_with_text ':sparkles: The 1st candidate just signed up'
  end

  def when_the_magic_link_token_is_overwritten
    Candidate.find_by(email_address: @email).update(magic_link_token: MagicLinkToken.new.raw)
  end

  def and_i_click_on_the_link_in_my_email
    current_email.find_css('a').first.click
  end

  def then_i_am_taken_to_the_expired_link_page
    expect(page).to have_current_path(candidate_interface_expired_sign_in_path, ignore_query: true)
  end

  def when_i_click_the_button_to_send_me_a_sign_in_email
    click_button t('authentication.expired_token.button')
  end

  def then_i_receive_an_email_inviting_me_to_sign_in
    open_email(@email)
    expect(current_email.subject).to have_content t('authentication.sign_in.email.subject')
  end

  def then_i_see_the_before_you_start_page
    expect(page).to have_current_path(candidate_interface_before_you_start_path)
  end

  def and_i_should_see_an_account_created_flash_message
    expect(page).to have_content(t('apply_from_find.account_created_message'))
  end

  def and_i_should_not_see_the_covid19_banner
    expect(page).not_to have_content 'There might be a delay in processing your application due to the impact of coronavirus (COVID-19)'
  end

  def when_click_on_the_apply_for_teacher_training_link_in_the_header
    click_link 'Apply for teacher training'
  end

  def then_i_should_see_the_application_page
    expect(page).to have_current_path(candidate_interface_application_form_path)
  end
end
