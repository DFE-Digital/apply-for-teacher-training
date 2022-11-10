require 'rails_helper'

RSpec.describe CandidateInterface::ReferenceHistoryComponent, time: Time.zone.local(2022, 10, 30), type: :component do
  shared_examples_for 'a reference history event' do |feedback_status, event_title|
    it 'renders the events of a reference history', with_audited: true do
      reference = create(:reference, :not_requested_yet)
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
end
