require 'rails_helper'

RSpec.describe CancelInterview do
  include CourseOptionHelpers

  let(:application_choice) { create(:application_choice, :awaiting_provider_decision, course_option: course_option) }
  let(:interview) { create(:interview, application_choice: application_choice) }
  let(:course_option) { course_option_for_provider(provider: provider) }
  let(:provider) { create(:provider) }
  let(:provider_user) { create(:provider_user, :with_set_up_interviews, providers: [provider]) }
  let(:service_params) do
    {
      actor: provider_user,
      application_choice: application_choice,
      interview: interview,
      cancellation_reason: 'There is a global pandemic going on',
    }
  end

  describe '#save!' do
    describe 'when there are no other interviews' do
      it 'transitions the application_choice state to `awaiting_provider_decision` if successful' do
        service = CancelInterview.new(service_params)

        expect { service.save! }.to change { application_choice.status }.to('awaiting_provider_decision')
      end
    end

    describe 'when there are other interviews' do
      it 'does not change the application_choice state' do
        create(:interview, application_choice: application_choice)
        service = CancelInterview.new(service_params)

        expect { service.save! }.not_to(change { application_choice.status })
      end
    end

    it 'creates an audit entry and sends an email', with_audited: true, sidekiq: true do
      CancelInterview.new(service_params).save!

      associated_audit = application_choice.associated_audits.last
      expect(associated_audit.auditable).to eq(application_choice.interviews.first)
      expect(associated_audit.audited_changes.keys).to eq(%w[
        cancelled_at cancellation_reason
      ])
      expect(associated_audit.audited_changes['cancellation_reason']).to eq([nil, 'There is a global pandemic going on'])

      expect(ActionMailer::Base.deliveries.first['rails-mail-template'].value).to eq('interview_cancelled')
    end
  end
end
