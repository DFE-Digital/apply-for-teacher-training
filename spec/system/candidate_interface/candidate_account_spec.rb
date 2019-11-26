require 'rails_helper'

RSpec.feature 'Candidate account' do
  scenario 'Candidate signs up, out, and in again' do
    given_the_pilot_is_open

    given_i_am_a_candidate_without_an_account

    when_i_visit_the_signup_page
    and_i_submit_my_email_address
    then_i_should_see_validation_errors_for_the_terms_and_conditions

    when_i_visit_the_signup_page
    and_i_accept_the_ts_and_cs
    and_i_submit_my_email_address
    then_i_receive_an_email_with_a_signup_link
    when_i_click_on_the_link_in_my_email
    then_i_am_signed_in

    when_i_click_the_sign_out_button
    then_i_should_be_signed_out

    when_i_click_the_signin_link
    and_i_submit_my_email_address
    then_i_receive_an_email_with_a_signin_link
    when_i_click_on_the_link_in_my_email
    then_i_am_signed_in

    when_i_click_the_sign_out_button

    when_i_visit_the_signup_page
    and_i_submit_my_email_address
    then_i_receive_an_email_with_a_signin_link
    when_i_click_on_the_link_in_my_email
    then_i_am_signed_in

    when_i_signed_in_more_than_a_week_ago
    then_i_should_be_signed_out
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def given_i_am_a_candidate_without_an_account
    @email = "#{SecureRandom.hex}@example.com"
  end

  def when_i_visit_the_signup_page
    visit '/'

    click_on t('application_form.begin_button')

    find('#candidate-interface-eligibility-form-eligible-citizen-yes-field').click
    find('#candidate-interface-eligibility-form-eligible-qualifications-yes-field').click

    click_on 'Continue'
  end

  def then_i_should_see_validation_errors_for_the_terms_and_conditions
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/sign_up_form.attributes.accept_ts_and_cs.blank')
  end

  def and_i_accept_the_ts_and_cs
    check t('authentication.sign_up.accept_terms_checkbox')
  end

  def and_i_submit_my_email_address
    fill_in t('authentication.sign_up.email_address.label'), with: @email
    click_on t('authentication.sign_up.button_continue')
  end

  def then_i_receive_an_email_with_a_signup_link
    open_email(@email)
    expect(current_email.subject).to have_content t('authentication.sign_up.email.subject')
  end

  def then_i_receive_an_email_with_a_signin_link
    open_email(@email)
    expect(current_email.subject).to have_content t('authentication.sign_in.email.subject')
  end

  def when_i_click_on_the_link_in_my_email
    current_email.find_css('a').first.click
  end

  def then_i_am_signed_in
    within 'header' do
      expect(page).to have_content @email
      expect(page).to have_link(href: candidate_interface_application_form_path)
    end
  end

  def when_i_click_the_sign_out_button
    click_link 'Sign out'
  end

  def then_i_should_be_signed_out
    expect(page).not_to have_selector :link_or_button, 'Sign out'
    expect(page).to have_current_path(candidate_interface_start_path)
  end

  def when_i_click_the_signin_link
    visit '/'
    click_on 'sign in'
  end

  def when_i_signed_in_more_than_a_week_ago
    Timecop.travel(Time.now + 7.days + 1.second) do
      visit candidate_interface_application_form_path
    end
  end
end
