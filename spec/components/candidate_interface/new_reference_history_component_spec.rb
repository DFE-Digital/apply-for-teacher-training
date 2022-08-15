require 'rails_helper'

RSpec.describe CandidateInterface::NewReferenceHistoryComponent, type: :component do
  it 'renders the events of a reference history', with_audited: true do
    reference = create(:reference, :not_requested_yet, created_at: Time.zone.local(2020, 1, 1, 9))
    Timecop.freeze(reference.created_at) { reference.feedback_requested! }
    Timecop.freeze(reference.created_at + 1.day) { reference.feedback_provided! }

    result = render_inline(described_class.new(reference))

    list_items = result.css('p')
    expect(list_items[0].text).to include 'Request sent'
    expect(list_items[0].text.squish).to include '1 January 2020'
    expect(list_items[1].text).to include 'Reference sent to provider'
    expect(list_items[1].text.squish).to include '2 January 2020'
  end

  it 'uses a special title format for request_bounced events', with_audited: true do
    reference = create(:reference, :not_requested_yet, email_address: 'example@email.com')
    reference.email_bounced!

    result = render_inline(described_class.new(reference))

    list_item = result.css('p').first
    expect(list_item.text).to include 'The request did not reach example@email.com'
  end

  it 'uses a special title format for request_sent events', with_audited: true do
    reference = create(:reference, :not_requested_yet, email_address: 'example@email.com')
    reference.feedback_requested!

    result = render_inline(described_class.new(reference))

    list_item = result.css('p').first
    expect(list_item.text).to include "Request sent #{Time.zone.now.to_fs(:govuk_date)}"
  end
end
