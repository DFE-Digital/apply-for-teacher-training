require 'rails_helper'

RSpec.describe CandidateInterface::ReferenceStatusLineComponent, type: :component do
  it 'renders a status line for request_bounced events', :with_audited do
    reference = create(:reference, :not_requested_yet, email_address: 'example@email.com')
    reference.email_bounced!

    result = render_inline(described_class.new(reference))

    list_item = result.css('p').first
    expect(list_item.text).to include 'Email could not be sent - check email address and send again'
  end

  it 'renders a status line for request_sent events', :with_audited do
    reference = create(:reference, :not_requested_yet, email_address: 'example@email.com')
    reference.update!(feedback_status: :feedback_requested, requested_at: Time.zone.now)

    result = render_inline(described_class.new(reference))

    list_item = result.css('p').first
    expect(list_item.text).to include "Request sent on #{Time.zone.now.to_fs(:govuk_date)}"
  end

  it 'renders cancel request link for reference feedback_feedback_status that is feedback_requested', :with_audited do
    reference = create(:reference, :not_requested_yet)
    reference.update!(feedback_status: :feedback_requested, requested_at: Time.zone.now)

    render_inline(described_class.new(reference)) do |rendered_component|
      expect(rendered_component).to have_no_text 'send a reminder'
      expect(rendered_component).to have_text '- cancel request'

      travel_temporarily_to(49.hours.from_now) do
        render_inline(described_class.new(reference))
        expect(rendered_component).to have_text 'send a reminder'
        expect(rendered_component).to have_text 'or cancel request'
      end
    end
  end

  it 'conditionally changes the cancel link when a reminder has been sent', :with_audited do
    reference = create(:reference, :not_requested_yet, reminder_sent_at: 1.day.ago)
    reference.update!(feedback_status: :feedback_requested, requested_at: Time.zone.now)

    render_inline(described_class.new(reference)) do |rendered_component|
      expect(rendered_component).to have_text '- cancel request'
    end
  end
end
