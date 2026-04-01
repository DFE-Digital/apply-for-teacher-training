require 'rails_helper'

RSpec.describe 'Support user filters emails by application form' do
  include DfESignInHelpers

  scenario do
    given_i_am_a_support_user
    and_an_emails_has_been_dispatched
    when_i_visit_the_email_logs_page_for_bobs_application
    then_i_see_an_email_for_bob
    and_i_do_not_see_an_email_for_jane
    and_i_see_the_application_form_filter
  end

private

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_an_emails_has_been_dispatched
    @bob_application_form = create(:completed_application_form)
    @jane_application_form = create(:completed_application_form)
    @bob_email = create(:email, to: 'bob@example.com', subject: 'Hello Bob', application_form: @bob_application_form)
    @jane_email = create(:email, to: 'jane@example.com', subject: 'Hello Jane', application_form: @jane_application_form)
  end

  def when_i_visit_the_email_logs_page_for_bobs_application
    visit support_interface_email_log_path(application_form_id: @bob_application_form.id)

    expect(page).to have_current_path('/support/email-log', ignore_query: true)
    expect(page).not_to have_element(:p, text: 'Select filters to search for emails.', class: 'govuk-body')
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

  def and_i_see_the_application_form_filter
    within('.moj-filter__content') do
      expect(page).to have_field('Application form', with: @bob_application_form.id)
    end
  end
end
