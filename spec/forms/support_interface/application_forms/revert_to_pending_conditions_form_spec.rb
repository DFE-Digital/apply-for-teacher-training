require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::RevertToPendingConditionsForm, :with_audited, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:accept_guidance) }
    it { is_expected.to validate_presence_of(:audit_comment_ticket) }

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
    let(:zendesk_ticket) { 'www.becomingateacher.zendesk.com/agent/tickets/example' }

    context 'when the application choice status is recruited' do
      it 'updates the provided ApplicationChoice status to pending_conditions if valid' do
        application_choice = create(:application_choice, :recruited)

        form = described_class.new(
          audit_comment_ticket: zendesk_ticket,
          accept_guidance: true,
        )

        expect(form.save(application_choice)).to be(true)

        expect(application_choice).to have_attributes({
          status: 'pending_conditions',
        })

        expect(application_choice.audits.last.comment).to include(zendesk_ticket)
      end
    end

    context 'when the application choice status is conditions_not_met' do
      it 'updates the provided ApplicationChoice status to pending_conditions if valid' do
        application_choice = create(:application_choice, :conditions_not_met)

        form = described_class.new(
          audit_comment_ticket: zendesk_ticket,
          accept_guidance: true,
        )

        expect(form.save(application_choice)).to be(true)

        expect(application_choice).to have_attributes({
          status: 'pending_conditions',
        })

        expect(application_choice.audits.last.comment).to include(zendesk_ticket)
      end
    end

    context 'when the application choice status is offer_deferred' do
      it 'updates the provided ApplicationChoice status to pending_conditions if valid' do
        application_choice = create(:application_choice, :offer_deferred)

        form = described_class.new(
          audit_comment_ticket: zendesk_ticket,
          accept_guidance: true,
        )

        expect(form.save(application_choice)).to be(true)

        expect(application_choice).to have_attributes({
          status: 'pending_conditions',
        })

        expect(application_choice.audits.last.comment).to include(zendesk_ticket)
      end
    end
  end
end
