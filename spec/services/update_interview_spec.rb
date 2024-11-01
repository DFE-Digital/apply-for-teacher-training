require 'rails_helper'

RSpec.describe UpdateInterview do
  include CourseOptionHelpers

  let(:application_choice) { create(:application_choice, :interviewing, course_option:) }
  let(:interview) { application_choice.interviews.first }
  let(:course_option) { course_option_for_provider(provider:) }
  let(:provider) { create(:provider) }
  let(:amended_date_and_time) { 1.day.since(interview.date_and_time) }
  let(:service_params) do
    {
      actor: provider_user,
      provider:,
      interview:,
      date_and_time: amended_date_and_time,
      location: 'Zoom call',
      additional_details: 'Business casual',
    }
  end

  let(:provider_user) { create(:provider_user, :with_set_up_interviews, providers: [provider]) }

  describe '#save!' do
    before do
      TestSuiteTimeMachine.unfreeze!
    end

    it 'updates the existing interview with provided params' do
      described_class.new(**service_params).save!

      expect(interview.provider).to eq(provider)
      expect(interview.date_and_time).to eq(amended_date_and_time)
      expect(interview.location).to eq('Zoom call')
      expect(interview.additional_details).to eq('Business casual')
    end

    it 'creates an audit entry and sends an email', :sidekiq, :with_audited do
      described_class.new(**service_params).save!

      associated_audit = application_choice.associated_audits.last
      expect(associated_audit.auditable).to eq(application_choice.interviews.first)
      expect(associated_audit.audited_changes.keys).to contain_exactly(
        'location',
        'date_and_time',
        'additional_details',
      )

      expect(associated_audit.audited_changes['location'].last).to eq('Zoom call')
      expect(associated_audit.audited_changes['additional_details'].last).to eq('Business casual')

      expect(ActionMailer::Base.deliveries.first.rails_mail_template).to eq('interview_updated')
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
        provider:,
        interview:,
        date_and_time: amended_date_and_time,
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
    let(:new_date_and_time_in_the_past) { 5.days.ago }
    let(:service_params) do
      {
        actor: provider_user,
        provider:,
        interview:,
        date_and_time: new_date_and_time_in_the_past,
        location: 'Zoom call',
        additional_details: 'Business casual',
      }
    end

    it 'raises a ValidationException, does not send emails' do
      expect { described_class.new(**service_params).save! }
        .to raise_error(ValidationException)

      expect(ActionMailer::Base.deliveries.map(&:rails_mail_template)).not_to include('interview_updated')
    end
  end

  context 'if interview workflow constraints fail', :sidekiq do
    let(:interview) { create(:interview, :cancelled, application_choice:) }
    let(:service_params) do
      {
        actor: provider_user,
        provider:,
        interview:,
        date_and_time: 3.days.from_now,
        location: 'Zoom call',
        additional_details: 'Business casual',
      }
    end

    it 'raises an InterviewWorkflowConstraints::WorkflowError, does not send emails' do
      expect { described_class.new(**service_params).save! }
        .to raise_error(InterviewWorkflowConstraints::WorkflowError)

      expect(ActionMailer::Base.deliveries.map(&:rails_mail_template)).not_to include('interview_updated')
    end
  end

  context 'if the update changes no fields', :sidekiq do
    let(:service_params) do
      {
        actor: provider_user,
        provider:,
        interview:,
        date_and_time: interview.date_and_time,
        location: interview.location,
        additional_details: interview.additional_details,
      }
    end

    it 'does not send emails' do
      described_class.new(**service_params).save!

      expect(ActionMailer::Base.deliveries.map(&:rails_mail_template)).not_to include('interview_updated')
    end
  end
end
