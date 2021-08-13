require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::ReinstateDeclinedOfferForm, type: :model, with_audited: true do
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

    it 'returns false if not valid' do
      course_choice = create(:application_choice, status: :offer)
      declined_offer_form = described_class.new

      expect(declined_offer_form.save(course_choice)).to eq(false)
    end

    it 'updates the provided ApplicationChoice with the "offer made" status if valid' do
      Timecop.freeze do
        course_choice = create(:application_choice, :with_declined_offer)

        declined_offer_form = described_class.new(
          { status: :declined,
            audit_comment_ticket: zendesk_ticket,
            accept_guidance: true },
        )

        expect(declined_offer_form.save(course_choice)).to eq(true)

        expect(course_choice).to have_attributes({
          status: 'offer',
          declined_at: nil,
          declined_by_default: false,
          decline_by_default_at: 10.business_days.from_now.end_of_day,
        })

        expect(course_choice.audits.last.comment).to include(zendesk_ticket)
      end
    end
  end
end
