require 'rails_helper'

RSpec.describe CreateInterview do
  include CourseOptionHelpers

  let(:application_choice) { create(:application_choice, :awaiting_provider_decision, course_option:) }
  let(:course_option) { course_option_for_provider(provider:) }
  let(:provider) { create(:provider) }
  let(:service_params) do
    {
      actor: provider_user,
      application_choice:,
      provider:,
      date_and_time: Time.zone.now,
      location: 'Zoom call',
      additional_details: '',
    }
  end

  let(:provider_user) { create(:provider_user, :with_set_up_interviews, providers: [provider]) }

  describe '#save!' do
    before do
      TestSuiteTimeMachine.unfreeze!
    end

    it 'transitions the application_choice state to `interviewing` if successful' do
      service = described_class.new(**service_params)

      expect { service.save! }.to change { application_choice.status }.to('interviewing')
    end

    it 'creates an audit entry and sends an email', :sidekiq, :with_audited do
      described_class.new(**service_params).save!

      associated_audit = application_choice.associated_audits.first
      expect(associated_audit.auditable).to eq(application_choice.interviews.first)
      expect(associated_audit.audited_changes.keys).to contain_exactly(
        'location',
        'provider_id',
        'date_and_time',
        'additional_details',
        'application_choice_id',
        'cancellation_reason',
        'cancelled_at',
      )
      expect(associated_audit.audited_changes['location']).to eq('Zoom call')

      expect(ActionMailer::Base.deliveries.first.rails_mail_template).to eq('new_interview')
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
        provider:,
        date_and_time: Time.zone.now,
        location: 'Zoom call',
        additional_details: 'Business casual',
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
    let(:date_and_time_in_the_past) { 5.days.ago }
    let(:service_params) do
      {
        actor: provider_user,
        application_choice:,
        provider:,
        date_and_time: date_and_time_in_the_past,
        location: 'Zoom call',
        additional_details: 'Business casual',
      }
    end

    it 'raises a ValidationException, does not send emails' do
      expect { described_class.new(**service_params).save! }
        .to raise_error(ValidationException)

      expect(ActionMailer::Base.deliveries.map(&:rails_mail_template)).not_to include('new_interview')
    end
  end

  context 'if interview workflow constraints fail', :sidekiq do
    let(:application_choice) { create(:application_choice, :offered, course_option:) }
    let(:service_params) do
      {
        actor: provider_user,
        application_choice:,
        provider:,
        date_and_time: 3.days.from_now,
        location: 'Zoom call',
        additional_details: 'Business casual',
      }
    end

    it 'raises an InterviewWorkflowConstraints::WorkflowError, does not send emails' do
      expect { described_class.new(**service_params).save! }
        .to raise_error(InterviewWorkflowConstraints::WorkflowError)

      expect(ActionMailer::Base.deliveries.map(&:rails_mail_template)).not_to include('new_interview')
    end
  end
end
