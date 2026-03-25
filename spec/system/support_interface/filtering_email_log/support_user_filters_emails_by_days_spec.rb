require 'rails_helper'

RSpec.describe 'Support user filters emails by days' do
  include DfESignInHelpers

  scenario do
    given_i_am_a_support_user
    and_an_emails_has_been_dispatched
    when_i_visit_the_email_logs_page
    then_i_do_not_see_the_days_ago_filter

    when_i_filter_emails_by_recipient
    then_i_see_an_email_for_bob
    and_i_do_not_see_an_email_for_jane
    and_i_do_not_see_an_email_for_bob_sent_11_days_ago
    and_i_see_the_days_ago_filter_prefilled_with_10

    when_i_filter_by_12_days_ago
    then_i_see_an_email_for_bob
    and_i_do_not_see_an_email_for_jane
    and_i_see_an_email_for_bob_sent_11_days_ago
  end

private

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_an_emails_has_been_dispatched
    @bob_email = create(:email, to: 'bob@example.com', subject: 'Hello Bob')
    @older_bob_email = create(:email, to: 'bob@example.com', subject: 'Invite Bob', created_at: 11.days.ago)
    @jane_email = create(:email, to: 'jane@example.com', subject: 'Hello Jane')
  end

  def when_i_visit_the_email_logs_page
    visit support_interface_email_log_path

    expect(page).to have_current_path('/support/email-log', ignore_query: true)
    expect(page).to have_element(:div, text: 'Select filters to search for emails.', class: 'govuk-inset-text')
  end

  def then_i_do_not_see_the_days_ago_filter
    expect(page).to have_no_field('Days ago')
  end

  def when_i_filter_emails_by_recipient
    within('.moj-filter__content') do
      fill_in 'Recipient (To)', with: 'bob@example.com'
      click_on 'Apply filters'
    end
  end

  def then_i_see_an_email_for_bob
    within('.govuk-table') do
      expect(page).to have_element(:dt, text: 'Status')
      expect(page).to have_element(:dd, text: @bob_email.delivery_status.humanize)
      expect(page).to have_element(:dt, text: 'Type')
      expect(page).to have_element(:dd, text: @bob_email.humanised_email_type)
      expect(page).to have_element(:dt, text: 'To')
      expect(page).to have_element(:dd, text: 'bob@example.com')
      expect(page).to have_element(:dt, text: 'Subject')
      expect(page).to have_element(:dd, text: 'Hello Bob')
      expect(page).to have_element(:dt, text: 'Application')
      expect(page).to have_element(:dd, text: @bob_email.application_form.full_name)
    end
  end

  def and_i_do_not_see_an_email_for_jane
    within('.govuk-table') do
      expect(page).not_to have_element(:dd, text: 'jane@example.com')
      expect(page).not_to have_element(:dd, text: 'Hello Jane')
    end
  end

  def and_i_do_not_see_an_email_for_bob_sent_11_days_ago
    within('.govuk-table') do
      expect(page).not_to have_element(:dd, text: 'Invite Bob')
    end
  end

  def and_i_see_the_days_ago_filter_prefilled_with_10
    expect(page).to have_field('Days ago', with: '10')
  end

  def when_i_filter_by_12_days_ago
    within('.moj-filter__content') do
      fill_in 'Days ago', with: 12
      click_on 'Apply filters'
    end
  end

  def and_i_see_an_email_for_bob_sent_11_days_ago
    within('.govuk-table') do
      expect(page).to have_element(:dt, text: 'Status')
      expect(page).to have_element(:dd, text: @older_bob_email.delivery_status.humanize)
      expect(page).to have_element(:dt, text: 'Type')
      expect(page).to have_element(:dd, text: @older_bob_email.humanised_email_type)
      expect(page).to have_element(:dt, text: 'To')
      expect(page).to have_element(:dd, text: 'bob@example.com')
      expect(page).to have_element(:dt, text: 'Subject')
      expect(page).to have_element(:dd, text: 'Invite Bob')
      expect(page).to have_element(:dt, text: 'Application')
      expect(page).to have_element(:dd, text: @older_bob_email.application_form.full_name)
    end
  end
end
