require 'rails_helper'

RSpec.describe SupportInterface::RevertRejection, :with_audited do
  describe '#save!' do
    it 'reverts the application choice status back to `awaiting_provider_decision` and sets an audit comment' do
      application_choice = create(:application_choice, :rejected)
      zendesk_ticket = 'becomingateacher.zendesk.com/agent/tickets/example'

      described_class.new(
        application_choice:,
        zendesk_ticket:,
      ).save!

      expect(application_choice.audits.last.comment).to include(zendesk_ticket)
      expect(application_choice.attributes.symbolize_keys).to match(
        a_hash_including({
          rejected_at: nil,
          structured_rejection_reasons: nil,
          rejection_reason: nil,
          rejection_reasons_type: nil,
          status: 'awaiting_provider_decision',
        }),
      )
    end
  end
end
