require 'rails_helper'

RSpec.feature 'See applications' do
  around do |example|
    Timecop.freeze(Time.zone.local(2019, 10, 1, 12, 0, 0)) do
      example.run
    end
  end

  scenario 'Support user visits application audit page' do
    given_i_am_a_support_user
    and_there_is_an_application_in_the_system_logged_by_a_candidate
    and_a_vendor_updates_the_application_status
    and_i_visit_the_support_page

    when_i_click_on_an_application_history
    then_i_should_be_on_the_application_history_page
    then_i_should_be_able_to_see_history_events
  end

  def given_i_am_a_support_user
    page.driver.browser.authorize('test', 'test')
  end

  def and_there_is_an_application_in_the_system_logged_by_a_candidate
    candidate = create :candidate, email_address: 'alice@example.com'

    Audited.audit_class.as_user(candidate) do
      application_form = create(
        :application_form,
        first_name: 'Alice',
        last_name: 'Wunder',
        candidate: candidate,
      )
      Timecop.freeze(Time.zone.local(2019, 10, 1, 12, 0, 1)) do
        @application_choice = create(
          :application_choice,
          application_form: application_form,
          status: 'application_complete',
        )
      end
    end
  end

  def and_a_vendor_updates_the_application_status
    vendor_api_user = create :vendor_api_user, email_address: 'bob@example.com'

    Timecop.freeze(Time.zone.local(2019, 10, 2, 12, 0, 0)) do
      Audited.audit_class.as_user(vendor_api_user) do
        @application_choice.update(status: 'rejected')
      end
    end
  end

  def and_i_visit_the_support_page
    visit support_interface_path
  end

  def when_i_click_on_an_application_history
    click_on 'History'
  end

  def then_i_should_be_on_the_application_history_page
    expect(page).to have_content 'Alice Wunder’s application history'
  end

  def then_i_should_be_able_to_see_history_events
    within('tbody tr:eq(1)') do
      expect(page).to have_content '2 October 2019'
      expect(page).to have_content '12:00'
      expect(page).to have_content 'Update Application Choice'
      expect(page).to have_content 'bob@example.com (Vendor API)'
      expect(page).to have_content 'status application_complete → rejected'
    end
    within('tbody tr:eq(2)') do
      expect(page).to have_content '1 October 2019'
      expect(page).to have_content '12:00'
      expect(page).to have_content 'Create Application Choice'
      expect(page).to have_content 'alice@example.com (Candidate)'
      expect(page).to have_content 'status application_complete'
      expect(page).to have_content 'personal_statement hello'
    end
    within('tbody tr:eq(3)') do
      expect(page).to have_content '1 October 2019'
      expect(page).to have_content '12:00'
      expect(page).to have_content 'Create Application Form'
      expect(page).to have_content 'alice@example.com (Candidate)'
      expect(page).to have_content 'first_name Alice'
      expect(page).to have_content 'last_name Wunder'
    end
  end
end
