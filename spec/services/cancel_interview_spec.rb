require 'rails_helper'

RSpec.describe CancelInterview do
  include CourseOptionHelpers

  let(:application_choice) { create(:application_choice, :awaiting_provider_decision, course_option:) }
  let(:interview) { create(:interview, application_choice:) }
  let(:course_option) { course_option_for_provider(provider:) }
  let(:provider) { create(:provider) }
  let(:service_params) do
    {
      actor: provider_user,
      application_choice:,
      interview:,
      cancellation_reason: 'There is a global pandemic going on',
    }
  end

  let(:provider_user) { create(:provider_user, :with_set_up_interviews, providers: [provider]) }

  describe '#save!' do
    before do
      TestSuiteTimeMachine.unfreeze!
    end

    describe 'when there are no other interviews' do
      it 'transitions the application_choice state to `awaiting_provider_decision` if successful' do
        service = described_class.new(**service_params)

        expect { service.save! }.to change { application_choice.status }.to('awaiting_provider_decision')
      end
    end

    describe 'when there are other interviews' do
      it 'does not change the application_choice state' do
        create(:interview, application_choice:)
        service = described_class.new(**service_params)

        expect { service.save! }.not_to(change { application_choice.status })
      end
    end

    it 'creates an audit entry and sends an email', :sidekiq, :with_audited do
      described_class.new(**service_params).save!

      associated_audit = application_choice.associated_audits.last
      expect(associated_audit.auditable).to eq(application_choice.interviews.first)
      expect(associated_audit.audited_changes.keys).to eq(%w[cancelled_at cancellation_reason])
      expect(associated_audit.audited_changes['cancellation_reason']).to eq([nil, 'There is a global pandemic going on'])

      expect(ActionMailer::Base.deliveries.first.rails_mail_template).to eq('interview_cancelled')
    end

    it 'touches the application choice' do
      expect {
        described_class.new(**service_params).save!
      }.to change(application_choice, :updated_at)
    end
  end

  context 'called via the API' do
    let(:vendor_api_user) { create(:vendor_api_user, vendor_api_token:) }
    let(:vendor_api_token) { create(:vendor_api_token, provider:) }
    let(:service_params) do
      {
        actor: vendor_api_user,
        application_choice:,
        interview:,
        cancellation_reason: 'There is a global pandemic going on',
      }
    end

    it 'accepts a vendor_api_user', :sidekiq, :with_audited do
      described_class.new(**service_params).save!

      associated_audit = application_choice.associated_audits.last
      expect(associated_audit.auditable).to eq(application_choice.interviews.first)
      expect(associated_audit.user).to eq(vendor_api_user)
    end
  end

  context 'if interview validations fail', :sidekiq do
    let(:service_params) do
      {
        actor: provider_user,
        application_choice:,
        interview:,
        cancellation_reason: nil,
      }
    end

    it 'raises a ValidationException, does not send emails' do
      expect { described_class.new(**service_params).save! }
        .to raise_error(ValidationException)

      expect(ActionMailer::Base.deliveries.map(&:rails_mail_template)).not_to include('interview_cancelled')
    end
  end

  context 'if interview workflow constraints fail', :sidekiq do
    let(:interview) { create(:interview, :cancelled, application_choice:) }
    let(:service_params) do
      {
        actor: provider_user,
        application_choice:,
        interview:,
        cancellation_reason: nil,
      }
    end

    it 'raises a ValidationException, does not send emails' do
      expect { described_class.new(**service_params).save! }
        .to raise_error(InterviewWorkflowConstraints::WorkflowError)

      expect(ActionMailer::Base.deliveries.map(&:rails_mail_template)).not_to include('interview_cancelled')
    end
  end
end
