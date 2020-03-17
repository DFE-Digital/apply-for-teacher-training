require 'rails_helper'

RSpec.feature 'Email log' do
  include DfESignInHelpers

  scenario 'Emails are logged' do
    given_i_am_a_support_user
    when_an_email_with_custom_reference_is_sent
    and_an_email_with_an_application_id_is_sent
    and_i_visit_the_email_log
    then_i_see_the_custom_reference_email_in_the_log
    then_i_see_the_application_reference_in_the_log
    then_i_see_the_all_emails_have_a_reference_in_the_log
    then_i_see_the_all_emails_have_a_type_in_the_log

    when_notify_tells_us_the_emails_have_not_been_delivered
    then_the_delivery_status_is_displayed_on_the_page
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def when_an_email_with_custom_reference_is_sent
    AuthenticationMailer.sign_up_email(
      candidate: create(:candidate, email_address: 'harry@example.com'),
      token: '123',
    ).deliver_now
  end

  def and_an_email_with_an_application_id_is_sent
    CandidateMailer.application_submitted(
      create(:application_form, first_name: 'Harry', last_name: 'Potter'),
    ).deliver_now
  end

  def and_i_visit_the_email_log
    visit support_interface_email_log_path
  end

  def then_i_see_the_custom_reference_email_in_the_log
    expect(page).to have_content 'harry@example.com'
  end

  def then_i_see_the_application_reference_in_the_log
    expect(page).to have_content 'Harry Potter'
  end

  def then_i_see_the_all_emails_have_a_reference_in_the_log
    Email.pluck(:notify_reference).each do |notify_reference|
      expect(notify_reference).not_to be_nil
    end
  end

  def then_i_see_the_all_emails_have_a_type_in_the_log
    expect(page).to have_content 'Application submitted (Candidate mailer)'
    expect(page).to have_content 'Sign up email (Authentication mailer)'
  end

  def when_notify_tells_us_the_emails_have_not_been_delivered
    page.driver.header 'Authorization', "Bearer #{ENV.fetch('GOVUK_NOTIFY_CALLBACK_API_KEY')}"

    Email.pluck(:notify_reference).each do |notify_reference|
      page.driver.submit(:post, '/integrations/notify/callback', {
        reference: notify_reference,
        status: 'permanent-failure',
      })

      expect(page.status_code).to be(200)
    end
  end

  def then_the_delivery_status_is_displayed_on_the_page
    visit support_interface_email_log_path
    expect(page).to have_content 'Permanent failure'
  end
end
