require 'rails_helper'

RSpec.feature 'Candidate account' do
  include CandidateHelper
  include SignInHelper

  scenario 'Candidate signs in from a new device and receives notification email' do
    given_the_pilot_is_open
    and_i_am_an_existing_candidate

    when_i_sign_in_and_out

    when_i_sign_in_from_a_new_device
    then_i_should_receive_a_notification_email
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def and_i_am_an_existing_candidate
    current_candidate
  end

  def when_i_sign_in_and_out
    visit candidate_interface_sign_in_path
    fill_in 'Enter your email address', with: current_candidate.email_address
    click_button t('continue')
    open_email(current_candidate.email_address)
    expect(current_email.subject).to have_content t('authentication.sign_in.email.subject')

    @magic_link = current_email.find_css('a').first
    @magic_link.click
    confirm_sign_in
    within 'header' do
      expect(page).to have_content current_candidate.email_address
    end

    click_link 'Sign out'
    expect(page).to have_current_path(candidate_interface_create_account_or_sign_in_path)
  end

  def when_i_sign_in_from_a_new_device
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return('192.168.0.1')
    allow_any_instance_of(ActionDispatch::Request).to receive(:user_agent).and_return('Firefox')
    # rubocop:enable RSpec/AnyInstance

    visit candidate_interface_sign_in_path
    fill_in 'Enter your email address', with: current_candidate.email_address
    click_button t('continue')
    open_email(current_candidate.email_address)
    expect(current_email.subject).to have_content t('authentication.sign_in.email.subject')

    @magic_link = current_email.find_css('a').first
    @magic_link.click
    confirm_sign_in
    within 'header' do
      expect(page).to have_content current_candidate.email_address
    end
  end

  def then_i_should_receive_a_notification_email
    open_email(current_candidate.email_address)
    expect(current_email).to have_content('We detected you signed into Apply for Teacher Training on a new device.')
    expect(current_email).to have_content('192.168.0.1')
    expect(current_email).to have_content('Firefox')
  end
end
