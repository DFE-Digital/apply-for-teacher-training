require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::DeleteApplicationForm, :with_audited, type: :model do
  include CourseOptionHelpers

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
    context 'if the application has already been submitted' do
      let(:application_form) { create(:application_form, :completed, submitted_application_choices_count: 1) }
      let(:actor) { create(:support_user) }

      it 'raises an error' do
        form = described_class.new(
          accept_guidance: true,
          audit_comment_ticket: 'https://becomingateacher.zendesk.com/agent/tickets/12345',
        )
        expect { form.save(actor:, application_form:) }.to raise_error(RuntimeError)
        expect(application_form.reload.date_of_birth).to be_present
      end
    end

    context 'if the application has not been submitted' do
      let(:application_form) { create(:application_form, :minimum_info) }
      let(:actor) { create(:support_user) }

      it 'deletes the application' do
        form = described_class.new(
          accept_guidance: true,
          audit_comment_ticket: 'https://becomingateacher.zendesk.com/agent/tickets/12345',
        )
        form.save(actor:, application_form:)
        expect(application_form.reload.first_name).not_to be_present
        expect(application_form.date_of_birth).not_to be_present
      end
    end
  end
end
