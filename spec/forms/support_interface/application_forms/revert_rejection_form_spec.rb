require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::RevertRejectionForm, type: :model, with_audited: true do
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

    it 'updates the provided ApplicationChoice with the `awaiting_provider_decision` status if valid' do
      Timecop.freeze do
        application_choice = create(:application_choice, :with_rejection)

        form = SupportInterface::ApplicationForms::RevertRejectionForm.new(
          audit_comment_ticket: zendesk_ticket,
          accept_guidance: true,
        )

        expect(form.save(application_choice)).to eq(true)

        expect(application_choice).to have_attributes({
          status: 'awaiting_provider_decision',
        })

        expect(application_choice.audits.last.comment).to include(zendesk_ticket)
      end
    end
  end
end
