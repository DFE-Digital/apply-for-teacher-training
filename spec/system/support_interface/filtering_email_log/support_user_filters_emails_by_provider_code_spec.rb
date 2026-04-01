require 'rails_helper'

RSpec.describe 'Support user filters emails by provider code' do
  include DfESignInHelpers

  scenario do
    given_i_am_a_support_user
    and_an_emails_has_been_dispatched
    when_i_visit_the_email_logs_page_for_bobs_application
    and_i_filter_emails_by_provider_code
    then_i_see_an_email_for_bob
    and_i_do_not_see_an_email_for_jane
    and_i_see_the_provider_code_filter
  end

private

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_an_emails_has_been_dispatched
    @provider = create(:provider, code: 'ZZZ')
    @provider_user_1 = create(:provider_user, providers: [@provider], email_address: 'bob@example.com')
    @provider_user_2 = create(:provider_user, providers: [@provider], email_address: 'harry@example.com')
    @random_provider_user = create(:provider_user, email_address: 'jane@example.com')
    @bob_email = create(:email, to: 'bob@example.com', subject: 'Hello Bob')
    @jane_email = create(:email, to: 'jane@example.com', subject: 'Hello Jane')
    @harry_email = create(:email, to: 'harry@example.com', subject: 'Hello Harry')
  end

  def when_i_visit_the_email_logs_page_for_bobs_application
    visit support_interface_email_log_path

    expect(page).to have_current_path('/support/email-log', ignore_query: true)
    expect(page).to have_element(:p, text: 'Select filters to search for emails.', class: 'govuk-body')
    expect(page).to have_element(:p, text: 'You must enter at least one of the follow fields:', class: 'govuk-body')
    expect(page).to have_element(:li, text: 'Application form ID')
    expect(page).to have_element(:li, text: 'Recipient (to)')
    expect(page).to have_element(:li, text: 'Provider code')
    expect(page).to have_element(:li, text: 'Notify reference')
  end

  def and_i_filter_emails_by_provider_code
    within('.moj-filter__content') do
      fill_in 'Provider code', with: 'ZZZ'
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

  def and_i_see_an_email_for_harry
    within('.govuk-table') do
      expect(page).to have_element(:dt, text: 'Status')
      expect(page).to have_element(:dd, text: @harry_email.delivery_status.humanize)
      expect(page).to have_element(:dt, text: 'Type')
      expect(page).to have_element(:dd, text: @harry_email.humanised_email_type)
      expect(page).to have_element(:dt, text: 'To')
      expect(page).to have_element(:dd, text: 'harry@example.com')
      expect(page).to have_element(:dt, text: 'Subject')
      expect(page).to have_element(:dd, text: 'Hello Harry')
      expect(page).to have_element(:dt, text: 'Application')
      expect(page).to have_element(:dd, text: @harry_email.application_form.full_name)
    end
  end

  def and_i_do_not_see_an_email_for_jane
    within('.govuk-table') do
      expect(page).not_to have_element(:dd, text: 'jane@example.com')
      expect(page).not_to have_element(:dd, text: 'Hello Jane')
    end
  end

  def and_i_see_the_provider_code_filter
    within('.moj-filter__content') do
      expect(page).to have_field('Provider code', with: 'ZZZ')
    end
  end
end
