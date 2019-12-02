require 'rails_helper'

RSpec.feature 'Candidate account' do
  scenario 'Two candidates on the same machine sign in one after the other' do
    given_the_pilot_is_open

    given_i_am_the_first_candidate
    then_i_can_sign_up_and_sign_out(@first_email)

    given_i_am_the_second_candidate
    then_i_can_sign_up_and_sign_out(@second_email)

    when_i_click_the_link_in_the_email_for(@first_email)
    then_i_am_signed_in_with(@first_email)

    when_i_click_the_link_in_the_email_for(@second_email)
    then_i_am_signed_in_with(@second_email)
  end

  def then_i_can_sign_up_and_sign_out(email)
    when_i_visit_the_signup_page
    and_i_accept_the_ts_and_cs
    and_i_submit_my_email_address(email)
    then_i_receive_an_email_with_a_signup_link(email)

    given_i_store_the_received_email_link_for(email)

    when_i_click_the_link_in_the_email_for(email)
    then_i_am_signed_in_with(email)

    when_i_click_the_sign_out_button
    then_i_should_be_signed_out
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def given_i_am_the_first_candidate
    @first_email = "first-#{SecureRandom.hex}@example.com"
  end

  def given_i_am_the_second_candidate
    @second_email = "second-#{SecureRandom.hex}@example.com"
  end

  def when_i_visit_the_signup_page
    visit '/'

    click_on t('application_form.begin_button')

    find('#candidate-interface-eligibility-form-eligible-citizen-yes-field').click
    find('#candidate-interface-eligibility-form-eligible-qualifications-yes-field').click

    click_on 'Continue'
  end

  def and_i_accept_the_ts_and_cs
    check t('authentication.sign_up.accept_terms_checkbox')
  end

  def and_i_submit_my_email_address(email)
    fill_in t('authentication.sign_up.email_address.label'), with: email
    click_on t('authentication.sign_up.button_continue')
  end

  def then_i_receive_an_email_with_a_signup_link(email)
    open_email(email)
    expect(current_email.subject).to have_content t('authentication.sign_up.email.subject')
  end

  def given_i_store_the_received_email_link_for(email)
    @email_link_for ||= {}
    @email_link_for[email] = current_email.find_css('a').first
  end

  def when_i_click_the_link_in_the_email_for(email)
    @email_link_for[email].click
  end

  def then_i_am_signed_in_with(email)
    within 'header' do
      expect(page).to have_content email
    end
  end

  def when_i_click_the_sign_out_button
    click_link 'Sign out'
  end

  def then_i_should_be_signed_out
    expect(page).not_to have_selector :link_or_button, 'Sign out'
    expect(page).to have_current_path(candidate_interface_start_path)
  end
end
