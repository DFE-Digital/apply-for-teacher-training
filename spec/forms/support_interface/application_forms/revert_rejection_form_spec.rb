require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::RevertRejectionForm, :with_audited, type: :model do
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
      application_choice = create(:application_choice, :rejected)

      form = described_class.new(
        audit_comment_ticket: zendesk_ticket,
        accept_guidance: true,
      )

      expect(form.save(application_choice)).to be(true)

      expect(application_choice).to have_attributes({
        status: 'awaiting_provider_decision',
      })

      expect(application_choice.audits.last.comment).to include(zendesk_ticket)
    end

    it 'returns false if the Application Choice has been duplicated for the same course' do
      course_option = create(:course_option)
      application_form = create(:completed_application_form)
      application_choice = create(:application_choice, :rejected, course_option:, application_form:)
      _duplicate_choice = create(:application_choice, :unsubmitted, course_option:, application_form:)
      form = described_class.new(
        audit_comment_ticket: zendesk_ticket,
        accept_guidance: true,
      )

      expect(form.save(application_choice)).to be(false)
    end
  end
end
