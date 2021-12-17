require 'rails_helper'

RSpec.feature 'Email log' do
  include DfESignInHelpers

  scenario 'Emails are logged' do
    given_i_am_a_support_user
    when_an_email_with_custom_reference_is_sent
    and_an_application_is_submitted
    and_an_email_with_an_application_id_is_sent
    and_i_visit_the_email_log
    then_i_see_the_custom_reference_email_in_the_log
    then_i_see_the_application_reference_in_the_log
    then_i_see_the_all_emails_have_a_reference_in_the_log
    then_i_see_the_all_emails_have_a_type_in_the_log

    when_notify_tells_us_the_emails_have_not_been_delivered
    then_the_delivery_status_is_displayed_on_the_page

    when_emails_to_other_recipients_have_been_sent
    and_i_search_by_email_address
    then_i_see_only_emails_that_match_the_supplied_address
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def when_an_email_with_custom_reference_is_sent
    @candidate = create(:candidate, email_address: 'harry@example.com')

    AuthenticationMailer.sign_up_email(
      candidate: @candidate,
      token: '123',
    ).deliver_now

    open_email('harry@example.com')
    expect(current_email.header('reference')).to start_with("#{HostingEnvironment.environment_name}-sign_up_email-#{@candidate.id}-")
  end

  def and_an_application_is_submitted
    @completed_application = create(
      :application_form,
      first_name: 'Harry',
      last_name: 'Potter',
      candidate: @candidate,
    )

    create(:application_choice, application_form: @completed_application, status: 'unsubmitted')

    SubmitApplication.new(@completed_application).call
  end

  def and_an_email_with_an_application_id_is_sent
    CandidateMailer.application_submitted(
      @completed_application,
    ).deliver_now

    open_email('harry@example.com')
    expect(current_email.header('reference')).not_to be_nil
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
    visit support_interface_email_log_path(delivery_status: 'permanent_failure')

    within '.moj-filter-layout__content' do
      expect(page).to have_content 'Permanent failure'
    end

    visit support_interface_email_log_path(delivery_status: 'delivered')

    within '.moj-filter-layout__content' do
      expect(page).not_to have_content 'Permanent failure'
    end
  end

  def when_emails_to_other_recipients_have_been_sent
    AuthenticationMailer.sign_up_email(
      candidate: create(:candidate, email_address: 'severus.snape@example.com'),
      token: '123',
    ).deliver_now
  end

  def and_i_search_by_email_address
    fill_in :q, with: 'harry@example'
    click_on 'Apply filters'
  end

  def then_i_see_only_emails_that_match_the_supplied_address
    expect(page).to have_selector('tbody tr', count: 3)
    expect(page).to have_content 'harry@example.com'
    expect(page).not_to have_content 'severus.snape@example.com'
  end
end
