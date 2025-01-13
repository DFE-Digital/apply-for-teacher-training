require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::RevertWithdrawalForm, :with_audited, type: :model do
  subject { described_class.new(application_choice: build(:application_choice)) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:accept_guidance) }

    context 'for an invalid zendesk link' do
      invalid_link = 'nonsense'
      it { is_expected.not_to allow_value(invalid_link).for(:audit_comment_ticket) }
    end

    context 'for an valid zendesk link' do
      valid_link = 'www.becomingateacher.zendesk.com/agent/tickets/example'
      it { is_expected.to allow_value(valid_link).for(:audit_comment_ticket) }
    end
  end

  describe '#save' do
    context 'valid' do
      let(:zendesk_ticket) { 'www.becomingateacher.zendesk.com/agent/tickets/example' }

      it 'updates the provided ApplicationChoice with the `awaiting_provider_decision` status if valid' do
        application_choice = create(:application_choice, :withdrawn)

        form = described_class.new(
          application_choice:,
          audit_comment_ticket: zendesk_ticket,
          accept_guidance: true,
        )

        expect(form.save).to be(true)

        expect(application_choice).to have_attributes({
          status: 'awaiting_provider_decision',
        })

        expect(application_choice.audits.last.comment).to include(zendesk_ticket)
      end

      it 'deletes associated withdrawal reasons' do
        application_choice = create(:application_choice, :withdrawn)
        create(:withdrawal_reason, application_choice:)

        form = described_class.new(
          application_choice:,
          audit_comment_ticket: zendesk_ticket,
          accept_guidance: true,
        )
        expect(form.save).to be(true)

        expect(application_choice.withdrawal_reasons).to be_empty
      end
    end

    context 'invalid' do
      it 'returns false and merges the application choice errors with the form errors' do
        application_choice = create(:application_choice, :withdrawn)
        allow(application_choice).to receive(:valid?) {
                                       application_choice.errors.add(:base, 'application choice error')
                                       false
                                     }

        form = described_class.new(
          application_choice:,
          audit_comment_ticket: nil,
        )

        expect(form.save).to be(false)

        expect(application_choice.errors.full_messages).to eq(['application choice error'])
        expect(form.errors.full_messages).to contain_exactly(
          'Accept guidance Select that you have read the guidance',
          'Audit comment ticket Enter a valid Zendesk ticket URL',
          'application choice error',
        )
      end
    end
  end
end
