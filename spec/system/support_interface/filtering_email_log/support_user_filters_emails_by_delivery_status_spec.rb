require 'rails_helper'

RSpec.describe 'Support user filters emails by delivery status' do
  include DfESignInHelpers

  scenario do
    given_i_am_a_support_user
    and_an_emails_has_been_dispatched
    when_i_visit_the_email_logs_page
    and_i_filter_emails_by_delivery_status
    then_i_see_i_must_enter_a_required_field

    when_i_filter_emails_by_application_form_id
    then_i_see_an_email_for_bob
    and_i_see_an_email_for_harry
    and_i_do_not_see_an_email_for_jane
  end

private

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_an_emails_has_been_dispatched
    @application_form = create(:application_form)
    @bob_email = create(:email, to: 'bob@example.com', subject: 'Hello Bob', delivery_status: :delivered, application_form: @application_form)
    @harry_email = create(:email, to: 'harry@example.com', subject: 'Hello Harry', delivery_status: :notify_error, application_form: @application_form)
    @jane_email = create(:email, to: 'jane@example.com', subject: 'Hello Jane', delivery_status: :pending, application_form: @application_form)
  end

  def when_i_visit_the_email_logs_page
    visit support_interface_email_log_path

    expect(page).to have_current_path('/support/email-log', ignore_query: true)
    expect(page).to have_element(:p, text: 'Select filters to search for emails.', class: 'govuk-body')
    and_i_see_i_must_enter_a_required_field
  end

  def when_i_filter_emails_by_application_form_id
    within('.moj-filter__content') do
      fill_in 'Application form ID', with: @application_form.id
      click_on 'Apply filters'
    end
  end

  def and_i_see_i_must_enter_a_required_field
    expect(page).to have_element(:p, text: 'You must enter at least one of the follow fields:', class: 'govuk-body')
    expect(page).to have_element(:li, text: 'Application form ID')
    expect(page).to have_element(:li, text: 'Recipient (to)')
    expect(page).to have_element(:li, text: 'Provider code')
    expect(page).to have_element(:li, text: 'Notify reference')
  end
  alias_method :then_i_see_i_must_enter_a_required_field, :and_i_see_i_must_enter_a_required_field

  def and_i_filter_emails_by_delivery_status
    within('.moj-filter__content') do
      check 'Delivered'
      check 'Notify error'
      click_on 'Apply filters'
    end
  end

  def then_i_see_an_email_for_bob
    within('.govuk-table') do
      expect(page).to have_element(:dt, text: 'Status')
      expect(page).to have_element(:dd, text: 'Delivered')
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
      expect(page).to have_element(:dd, text: 'Notify error')
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
      expect(page).not_to have_element(:dd, text: 'Pending')
    end
  end
end
