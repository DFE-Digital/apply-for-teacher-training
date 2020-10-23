require 'rails_helper'

RSpec.feature 'Reference history on review page' do
  include CandidateHelper

  scenario 'candidate views reference history', with_audited: true do
    given_i_am_signed_in
    and_i_add_a_reference
    and_i_send_it
    and_i_send_a_reminder
    and_i_cancel_the_reference
    then_i_see_a_history_of_these_events_on_the_review_page
    and_i_do_not_see_these_when_reviewing_the_entire_application
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_add_a_reference
    current_candidate.current_application.update!(first_name: 'Michael', last_name: 'Render')
    visit candidate_interface_decoupled_references_start_path
    click_link 'Continue'
    choose 'Academic'
    click_button 'Save and continue'

    candidate_fills_in_referee
  end

  def and_i_send_it
    Timecop.travel(Time.zone.local(2020, 1, 1, 14)) do
      choose 'Yes, send a reference request now'
      click_button 'Save and continue'
    end
  end

  def and_i_send_a_reminder
    Timecop.travel(Time.zone.local(2020, 1, 2, 14)) do
      click_link 'Send a reminder to this referee'
      click_button 'Yes I’m sure - send a reminder'
    end
  end

  def and_i_cancel_the_reference
    Timecop.travel(Time.zone.local(2020, 1, 3, 14)) do
      click_link 'Cancel request'
      click_button 'Yes I’m sure - cancel this reference request'
    end
  end

  def then_i_see_a_history_of_these_events_on_the_review_page
    expect(page).to have_content 'History'
    expected_history = [
      { event_name: 'Request sent', timestamp: '1 January 2020 at 2:00pm' },
      { event_name: 'Reminder sent', timestamp: '2 January 2020 at 2:00pm' },
      { event_name: 'Request cancelled', timestamp: '3 January 2020 at 2:00pm' },
    ]
    within '[data-qa="reference-history"]' do
      all('li').zip(expected_history).each do |rendered, expected|
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
