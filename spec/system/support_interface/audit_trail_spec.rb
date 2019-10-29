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
        )
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
    expect(page).to have_content 'Application History - Alice Wunder'
  end

  def then_i_should_be_able_to_see_history_events
    within('tbody tr:eq(1)') do
      expect(page).to have_content '2019-10-01 12:00:01'
      expect(page).to have_content 'Create Application Choice - alice@example.com (Candidate)'
    end
    within('tbody tr:eq(2)') do
      expect(page).to have_content '2019-10-01 12:00:00'
      expect(page).to have_content 'Create Application Form - alice@example.com (Candidate)'
    end
  end
end
