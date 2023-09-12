require 'rails_helper'

RSpec.describe CandidateInterface::ReferenceHistoryComponent, :with_audited, time: Time.zone.local(2022, 10, 30), type: :component do
  let(:application_form) { create(:application_form) }
  let(:reference) { create(:reference, :not_requested_yet, application_form:) }
  let(:result) { render_inline(described_class.new(reference)) }
  let(:events) { result.css('p').map(&:text).join("\n") }

  shared_examples_for 'a reference history event' do |feedback_status, event_title|
    it 'renders the events of a reference history' do
      travel_temporarily_to(reference.created_at) { reference.feedback_requested! }
      travel_temporarily_to(reference.created_at + 1.day) do
        reference.send("#{feedback_status}!") unless feedback_status == :feedback_requested
      end
      result = render_inline(described_class.new(reference))
      events = result.css('p').map(&:text).join("\n")

      expect(events).to include(event_title)
    end
  end

  it_behaves_like 'a reference history event', :feedback_requested, 'You sent the request on 30 October 2022'
  it_behaves_like 'a reference history event', :feedback_provided, 'They gave a reference to the training provider on 31 October 2022'
  it_behaves_like 'a reference history event', :cancelled, 'You cancelled the request on 31 October 2022'
  it_behaves_like 'a reference history event', :feedback_refused, 'They said they cannot give a reference on 31 October 2022'
  it_behaves_like 'a reference history event', :email_bounced, 'The request failed on 31 October 2022'

  context 'when automated reminder is sent' do
    it 'renders the events of a reference history', :with_audited do
      travel_temporarily_to(reference.created_at) { reference.feedback_requested! }
      travel_temporarily_to(reference.created_at + 8.days) do
        create(:chaser_sent, chased: reference, chaser_type: :referee_reference_request)
      end

      expect(events).to include('A reminder was automatically sent on 7 November 2022')
    end
  end

  context 'when candidate reminder is sent' do
    it 'renders the event name' do
      travel_temporarily_to(reference.created_at) { reference.feedback_requested! }
      travel_temporarily_to(reference.created_at + 1.day) do
        reference.update!(reminder_sent_at: Time.zone.now)
      end

      expect(events).to include('You sent a reminder on 31 October 2022')
    end
  end

  context 'when is cancelled' do
    before do
      travel_temporarily_to(reference.created_at) { reference.feedback_requested! }
      travel_temporarily_to(reference.created_at + 1.day) do
        reference.cancelled!
      end
    end

    context 'when candidate application did not meet conditions' do
      it 'renders the event name' do
        travel_temporarily_to(reference.created_at + 10.days) do
          create(:application_choice, :conditions_not_met, application_form:)
        end

        expect(events).to include('The request was automatically cancelled because you did not meet your conditions on 31 October 2022')
      end
    end

    context 'when candidate application is withdraw' do
      it 'renders the event name' do
        travel_temporarily_to(reference.created_at + 10.days) do
          create(:application_choice, :withdrawn, application_form:)
        end

        expect(events).to include('The request was automatically cancelled because you withdrew your application on 31 October 2022')
      end
    end

    context 'when candidate applications are withdraw and one offer accepted' do
      it 'does not render the withdraw event name' do
        travel_temporarily_to(reference.created_at + 10.days) do
          create(:application_choice, :pending_conditions, application_form:)
          create(:application_choice, :withdrawn, application_form:)
        end

        expect(events).to include('You cancelled the request on 31 October 2022')
      end
    end

    context 'when candidate offer is withdraw' do
      it 'renders the event name' do
        travel_temporarily_to(reference.created_at + 10.days) do
          create(:application_choice, :offer_withdrawn, application_form:)
        end
        expect(events).to include('The request was automatically cancelled because your offer was withdrawn on 31 October 2022')
      end
    end
  end
end
