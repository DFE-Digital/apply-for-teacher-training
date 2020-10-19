require 'rails_helper'

RSpec.describe ReferenceHistoryComponent, type: :component do
  it 'renders the requested_at time if present' do
    reference = build(:reference)
    result = render_inline(described_class.new(reference))
    expect(result.text).not_to include 'Request sent'

    reference.requested_at = Time.zone.local(2020, 1, 1, 13, 30)
    result = render_inline(described_class.new(reference))
    expect(result.text).to include 'Request sent'
    expect(result.text).to include '1 January 2020 at  1:30pm'
  end

  it 'renders the reminder_sent_at time if present' do
    reference = build(:reference)
    result = render_inline(described_class.new(reference))
    expect(result.text).not_to include 'Reminder sent'

    reference.reminder_sent_at = Time.zone.local(2020, 1, 1, 13, 30)
    result = render_inline(described_class.new(reference))
    expect(result.text).to include 'Reminder sent'
    expect(result.text).to include '1 January 2020 at  1:30pm'
  end
end
