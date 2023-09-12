require 'rails_helper'

RSpec.describe SupportInterface::RevertRecruitedToPendingConditions, :with_audited do
  let(:application_choice) { create(:application_choice, :recruited) }
  let(:zendesk_ticket) { 'becomingateacher.zendesk.com/agent/tickets/example' }

  describe '#save!' do
    it 'reverts the application choice status back to `pending_conditions` and sets an audit comment' do
      described_class.new(
        application_choice:,
        zendesk_ticket:,
      ).save!

      expect(application_choice.audits.last.comment).to include(zendesk_ticket)
      expect(application_choice.attributes.symbolize_keys).to match(
        a_hash_including({
          recruited_at: nil,
          accepted_at: nil,
          status: 'pending_conditions',
        }),
      )
    end

    it 'updates the status of all conditions to pending' do
      application_choice.offer.conditions.update(status: :met)

      expect { described_class.new(application_choice:, zendesk_ticket:).save! }.to change { application_choice.offer.conditions.first.status }.from('met').to('pending')
    end
  end
end
