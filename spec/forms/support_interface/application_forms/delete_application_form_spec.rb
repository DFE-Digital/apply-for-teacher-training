require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::ChangeCourseChoiceForm, type: :model, with_audited: true do
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

  describe '#save!' do
    context 'if the application has already been submitted' do
      it 'raises an error' do
      end
    end

    context 'if the application has not been submitted' do
      it 'deletes the application' do
      end
    end
  end
end
