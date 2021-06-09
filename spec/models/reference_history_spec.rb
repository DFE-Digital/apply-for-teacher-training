require 'rails_helper'

RSpec.describe ReferenceHistory do
  describe '#all_events' do
    it 'returns the event history for a successful reference', with_audited: true do
      reference = create(:reference, :not_requested_yet, email_address: 'ericandre@email.com')
      start_time = reference.created_at
      Timecop.freeze(start_time + 1.day) { reference.feedback_requested! }
      Timecop.freeze(start_time + 2.days) { reference.email_bounced! }
      Timecop.freeze(start_time + 3.days) { reference.feedback_requested! }
      Timecop.freeze(start_time + 4.days) { reference.update!(reminder_sent_at: Time.zone.now) }
      Timecop.freeze(start_time + 5.days) { reference.feedback_provided! }

      events = described_class.new(reference).all_events

      expected_attributes = [
        { name: 'request_sent', time: start_time + 1.day, extra_info: OpenStruct.new(email_address: 'ericandre@email.com') },
        { name: 'request_bounced', time: start_time + 2.days, extra_info: OpenStruct.new(bounced_email: 'ericandre@email.com') },
        { name: 'request_sent', time: start_time + 3.days, extra_info: OpenStruct.new(email_address: 'ericandre@email.com') },
        { name: 'reminder_sent', time: start_time + 4.days, extra_info: nil },
        { name: 'reference_received', time: start_time + 5.days, extra_info: nil },
      ]
      compare_data(expected_attributes, events)
    end

    it 'returns the event history for a failed reference', with_audited: true do
      reference = create(:reference, :not_requested_yet, email_address: 'ericandre@email.com')
      start_time = reference.created_at
      Timecop.freeze(start_time + 1.day) { reference.feedback_requested! }
      Timecop.freeze(start_time + 2.days) { reference.feedback_refused! }

      events = described_class.new(reference).all_events

      expected_attributes = [
        { name: 'request_sent', time: start_time + 1.day, extra_info: OpenStruct.new(email_address: 'ericandre@email.com') },
        { name: 'request_declined', time: start_time + 2.days, extra_info: nil },
      ]
      compare_data(expected_attributes, events)
    end

    it 'returns as many events for each event type as exists in the audit log', with_audited: true do
      reference = create(:reference, :not_requested_yet, email_address: 'ericandre@email.com')
      2.times do
        reference.feedback_requested!
        reference.cancelled!
        reference.update!(reminder_sent_at: Time.zone.now)
        reference.email_bounced!
        reference.feedback_provided!
        reference.feedback_refused!
      end
      create(:chaser_sent, chaser_type: :reference_request, chased: reference)
      create(:chaser_sent, chaser_type: :follow_up_missing_references, chased: reference)

      events = described_class.new(reference).all_events

      all_event_names.each do |event_name|
        expect(events.select { |e| e.name == event_name }.size).to eq 2
      end
    end

    it 'detects two types of cancel', with_audited: true do
      reference = create(:reference, :not_requested_yet, email_address: 'ericandre@email.com')
      reference.cancelled!
      reference.cancelled_at_end_of_cycle!

      events = described_class.new(reference).all_events

      expect(events.size).to eq 2
      events.each { |e| expect(e.name).to eq 'request_cancelled' }
    end

  private

    def compare_data(expected_attributes, events)
      expect(events.size).to eq expected_attributes.size
      expected_attributes.each_with_index do |attr, index|
        returned_event = events[index]
        expect(returned_event.name).to eq attr[:name]
        expect(returned_event.time).to eq attr[:time]
        expect(returned_event.extra_info).to eq attr[:extra_info]
      end
    end

    def all_event_names
      %w[
        request_sent
        request_cancelled
        reminder_sent
        request_bounced
        request_declined
        reference_received
        automated_reminder_sent
      ]
    end
  end
end
