require 'rails_helper'

RSpec.feature 'Reference history on review page' do
  include CandidateHelper

  around do |example|
    Timecop.freeze { example.run }
  end

  scenario 'candidate views reference history', with_audited: true do
    given_i_am_signed_in
    and_i_add_a_reference
    and_i_send_it
    and_i_send_a_reminder
    and_the_system_sends_an_automated_reminder
    then_i_see_a_history_of_these_events_on_the_review_page
    and_i_do_not_see_these_when_reviewing_the_entire_application
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_add_a_reference
    current_candidate.current_application.update!(first_name: 'Michael', last_name: 'Render')
    visit candidate_interface_references_start_path
    click_link t('continue')
    choose 'Academic'
    click_button t('save_and_continue')

    candidate_fills_in_referee
    @reference = current_candidate.current_application.application_references.first
  end

  def and_i_send_it
    Timecop.freeze(Time.zone.now + 2.hours) do
      choose 'Yes, send a reference request now'
      click_button t('save_and_continue')
    end
    @reference.reload
  end

  def and_i_send_a_reminder
    Timecop.freeze(@reference.requested_at + 1.day) do
      click_link 'Send a reminder to this referee'
      click_button 'Yes I’m sure - send a reminder'
    end
  end

  def and_the_system_sends_an_automated_reminder
    Timecop.freeze(@reference.requested_at + TimeLimitConfig.chase_referee_by.days + 1.minute) do
      ChaseReferences.new.perform
    end
  end

  def then_i_see_a_history_of_these_events_on_the_review_page
    visit candidate_interface_references_review_path
    expect(page).to have_content 'History'
    expected_history = [
      { event_name: 'Request sent', timestamp: (Time.zone.now + 2.hours).to_s(:govuk_date_and_time) },
      { event_name: 'Reminder sent', timestamp: (Time.zone.now + 1.day + 2.hours).to_s(:govuk_date_and_time) },
      { event_name: 'Automated reminder sent', timestamp: (Time.zone.now + 7.days + 2.hours + 1.minute).to_s(:govuk_date) },
    ]

    within '[data-qa="reference-history"]' do
      rendered_entries = all('li')
      expect(rendered_entries.size).to eq 3
      expected_history.zip(rendered_entries).each do |expected, rendered|
        expect(rendered.text).to include expected[:event_name]
        expect(rendered.text).to include expected[:timestamp]
      end
    end
  end

  def and_i_do_not_see_these_when_reviewing_the_entire_application
    create(:reference, :feedback_provided, application_form: current_candidate.current_application)
    create(:reference, :feedback_provided, application_form: current_candidate.current_application)
    visit candidate_interface_application_form_path
    click_link 'Check and submit your application'

    expect(page).not_to have_content 'History'
    expect(page).not_to have_content 'Request sent'
  end
end
