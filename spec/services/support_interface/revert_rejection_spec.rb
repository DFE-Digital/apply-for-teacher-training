require 'rails_helper'

RSpec.describe SupportInterface::RevertRejection, with_audited: true do
  describe '#save!' do
    it 'reverts the application choice status back to `awaiting_provider_decision` and sets an audit comment' do
      application_choice = create(:application_choice, :with_rejection)
      zendesk_ticket = 'becomingateacher.zendesk.com/agent/tickets/example'

      described_class.new(
        application_choice: application_choice,
        zendesk_ticket: zendesk_ticket,
      ).save!

      expect(application_choice).to be_awaiting_provider_decision
      expect(application_choice.audits.last.comment).to include(zendesk_ticket)
    end
  end
end
