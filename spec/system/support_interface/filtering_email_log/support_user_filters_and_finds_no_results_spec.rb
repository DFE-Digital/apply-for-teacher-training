require 'rails_helper'

RSpec.describe 'Support user filters and finds no results' do
  include DfESignInHelpers

  scenario do
    given_i_am_a_support_user
    and_an_emails_has_been_dispatched
    when_i_visit_the_email_logs_page
    and_i_filter_emails_by_an_invalid_recipient
    then_i_no_emails_have_been_found
  end

private

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_an_emails_has_been_dispatched
    @bob_email = create(:email, to: 'bob@example.com', subject: 'Hello Bob')
    @jane_email = create(:email, to: 'jane@example.com', subject: 'Hello Jane')
  end

  def when_i_visit_the_email_logs_page
    visit support_interface_email_log_path

    expect(page).to have_current_path('/support/email-log', ignore_query: true)
    expect(page).to have_element(:div, text: 'Select filters to search for emails.', class: 'govuk-inset-text')
  end

  def and_i_filter_emails_by_an_invalid_recipient
    within('.moj-filter__content') do
      fill_in 'Recipient (To)', with: 'invalid@example.com'
      click_on 'Apply filters'
    end
  end

  def then_i_no_emails_have_been_found
    within('.govuk-inset-text') do
      expect(page).to have_element(:p, text: 'There are no emails found for the selected filters.', class: 'govuk-body')
      expect(page).to have_element(:p, text: 'Try changing the selected filters.', class: 'govuk-body')
      expect(page).to have_element(:p, text: 'Ensure that the recipient email address and notify reference match exactly.', class: 'govuk-body')
    end
  end
end
