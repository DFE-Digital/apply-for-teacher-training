require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::DeleteReferenceForm do
  subject { described_class.new({ reference: build(:reference) }) }

  context 'validations' do
    it { is_expected.to validate_presence_of(:actor) }
    it { is_expected.to validate_presence_of(:accept_guidance) }
    it { is_expected.to validate_presence_of(:audit_comment_ticket) }

    it 'is not valid if the reference has a safeguarding concern' do
      reference = build(:reference, :has_safeguarding_concerns_to_declare)
      form = described_class.new(reference:)

      expect(form).not_to be_valid
      expect(form.errors[:reference]).to include('Cannot delete reference with a safeguarding concern')
    end
  end

  describe '#save' do
    it 'returns false if the form is invalid' do
      reference = build(:reference)
      form = described_class.new(reference:)

      expect(form.save).to be_falsey
    end

    it 'calls the DeleteReference service with the correct parameters' do
      service_double = instance_double(SupportInterface::DeleteReference, call!: true)
      allow(SupportInterface::DeleteReference).to receive(:new).and_return(service_double)

      actor = build(:support_user)
      reference = build(:reference)
      zendesk_url = 'https://becomingateacher.zendesk.com/agent/tickets/123456'
      form = described_class.new(
        reference:,
        accept_guidance: true,
        audit_comment_ticket: zendesk_url,
        actor: actor,
      )

      form.save

      expect(service_double).to have_received(:call!)
                                  .with(actor: actor, reference: reference, zendesk_url: zendesk_url)
    end
  end
end
