require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::UpdateOfferedCourseOptionForm, with_audited: true do
  describe '#validations' do
    it { is_expected.to validate_presence_of(:course_option_id) }
    it { is_expected.to validate_presence_of(:audit_comment) }
    it { is_expected.to validate_presence_of(:accept_guidance) }

    context 'for an invalid zendesk link' do
      invalid_link = 'nonsense'
      it { is_expected.not_to allow_value(invalid_link).for(:audit_comment) }
    end

    context 'for an valid zendesk link' do
      valid_link = 'www.becomingateacher.zendesk.com/agent/tickets/example'
      it { is_expected.to allow_value(valid_link).for(:audit_comment) }
    end
  end

  describe '#save' do
    it 'updates the offered course option' do
      application_choice = create(:application_choice, status: :offer)
      replacement_course_option = create(:course_option)
      zendesk_ticket = 'www.becomingateacher.zendesk.com/agent/tickets/example'

      described_class.new(course_option_id: replacement_course_option.id, audit_comment: zendesk_ticket, accept_guidance: 'true').save(application_choice)

      expect(application_choice.reload.current_course_option_id).to eq replacement_course_option.id
      expect(application_choice.audits.last.comment).to include(zendesk_ticket)
    end
  end
end
