require 'rails_helper'

RSpec.describe SupportInterface::RevertWithdrawal, with_audited: true do
  describe '#save!' do
    it 'reverts the application choice status back to `awaiting_provider_decision` and sets an audit comment' do
      application_choice = create(:application_choice, :awaiting_provider_decision)
      original_application_choice = application_choice.clone

      zendesk_ticket = 'becomingateacher.zendesk.com/agent/tickets/example'

      WithdrawApplication.new(
        application_choice:,
      ).save!
      described_class.new(
        application_choice:,
        zendesk_ticket:,
      ).save!

      expect(application_choice).to eq(original_application_choice)
      expect(application_choice.audits.last.comment).to include(zendesk_ticket)
      expect(application_choice.withdrawn_or_declined_for_candidate_by_provider).to be_nil
    end
  end
end
