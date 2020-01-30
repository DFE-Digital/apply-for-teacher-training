require 'rails_helper'

RSpec.feature 'Candidate clicks on an expired link', sidekiq: true do
  scenario 'Candidate clicks on a link with an id and expired token link in an email' do
    given_the_pilot_is_open
    and_the_improved_expired_token_flow_feature_flag_is_on
    and_i_am_a_candidate_with_an_application
    and_i_received_the_submitted_application_email

    when_i_click_on_the_sign_in_link_with_an_id
    then_i_am_redirected_to_the_expired_link_page

    when_i_click_the_button_to_send_me_a_sign_in_email
    then_i_receive_a_sign_in_email
    and_i_see_the_check_your_email_page

    when_i_visit_the_sign_in_page_with_an_invalid_id_parameter
    then_i_am_taken_to_the_sign_in_page

    when_i_visit_the_expired_sign_in_page_without_id_parameter
    then_i_am_taken_to_the_sign_in_page

    when_i_fill_in_the_sign_in_form

    when_i_click_on_the_sign_in_link_with_token_after_one_hour
    then_i_am_redirected_to_the_expired_link_page
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def and_the_improved_expired_token_flow_feature_flag_is_on
    FeatureFlag.activate('improved_expired_token_flow')
  end

  def and_i_am_a_candidate_with_an_application
    @candidate = create(:candidate)
    @application_form = create(:application_form, candidate: @candidate)
  end

  def and_i_received_the_submitted_application_email
    CandidateMailer.submit_application_email(@application_form).deliver_now
  end

  def when_i_click_on_the_sign_in_link_with_an_id
    open_email(@candidate.email_address)
    current_email.find_css('a').first.click
  end

  def then_i_am_redirected_to_the_expired_link_page
    expect(page).to have_content(t('authentication.expired_token.heading'))
  end

  def when_i_click_the_button_to_send_me_a_sign_in_email
    click_button t('authentication.expired_token.button')
  end

  def then_i_receive_a_sign_in_email
    open_email(@candidate.email_address)
    expect(current_email.subject).to have_content t('authentication.sign_in.email.subject')
  end

  def and_i_see_the_check_your_email_page
    expect(page).to have_content('Check your email')
  end

  def when_i_visit_the_sign_in_page_with_an_invalid_id_parameter
    visit candidate_interface_sign_in_path(u: 'unencrypted_candidate_id')
  end

  def then_i_am_taken_to_the_sign_in_page
    expect(page).to have_content(t('page_titles.sign_in'))
  end

  def when_i_visit_the_expired_sign_in_page_without_id_parameter
    visit candidate_interface_expired_sign_in_path
  end

  def when_i_fill_in_the_sign_in_form
    fill_in t('authentication.sign_up.email_address.label'), with: @candidate.email_address
    click_on 'Continue'
  end

  def when_i_click_on_the_sign_in_link_with_token_after_one_hour
    Timecop.travel(Time.zone.now + 1.hour + 1.minute) do
      open_email(@candidate.email_address)

      current_email.find_css('a').first.click
    end
  end
end
