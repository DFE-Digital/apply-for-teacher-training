require 'rails_helper'

RSpec.describe UpdateInterview do
  include CourseOptionHelpers

  let(:application_choice) { create(:application_choice, :with_scheduled_interview, course_option: course_option) }
  let(:interview) { application_choice.interviews.first }
  let(:course_option) { course_option_for_provider(provider: provider) }
  let(:provider) { create(:provider) }
  let(:amended_date_and_time) { 1.day.since(interview.date_and_time) }
  let(:service_params) do
    {
      actor: provider_user,
      provider: provider,
      interview: interview,
      date_and_time: amended_date_and_time,
      location: 'Zoom call',
      additional_details: 'Business casual',
    }
  end

  context 'when the interview_permissions feature_flag is active' do
    before do
      FeatureFlag.activate(:interview_permissions)
    end

    let(:provider_user) { create(:provider_user, :with_set_up_interviews, providers: [provider]) }

    describe '#save!' do
      it 'updates the existing interview with provided params' do
        described_class.new(service_params).save!

        expect(interview.provider).to eq(provider)
        expect(interview.date_and_time).to eq(amended_date_and_time)
        expect(interview.location).to eq('Zoom call')
        expect(interview.additional_details).to eq('Business casual')
      end

      context 'if the interview is not changed' do
        let(:service_params) do
          {
            actor: provider_user,
            provider: interview.provider,
            interview: interview,
            date_and_time: interview.date_and_time,
            location: interview.location,
            additional_details: interview.additional_details,
          }
        end

        it 'an email is not sent', sidekiq: true do
          described_class.new(service_params).save!

          expect(ActionMailer::Base.deliveries.map { |d| d['rails-mail-template'].value }).not_to include('interview_updated')
        end
      end

      it 'creates an audit entry and sends an email', with_audited: true, sidekiq: true do
        described_class.new(service_params).save!

        associated_audit = application_choice.associated_audits.last
        expect(associated_audit.auditable).to eq(application_choice.interviews.first)
        expect(associated_audit.audited_changes.keys).to contain_exactly(
          'location',
          'date_and_time',
          'additional_details',
        )

        expect(associated_audit.audited_changes['location'].last).to eq('Zoom call')
        expect(associated_audit.audited_changes['additional_details'].last).to eq('Business casual')

        expect(ActionMailer::Base.deliveries.first['rails-mail-template'].value).to eq('interview_updated')
      end
    end
  end

  context 'when the interview_permissions feature_flag is inactive' do
    before do
      FeatureFlag.deactivate(:interview_permissions)
    end

    let(:provider_user) { create(:provider_user, :with_make_decisions, providers: [provider]) }

    describe '#save!' do
      it 'updates the existing interview with provided params' do
        described_class.new(service_params).save!

        expect(interview.provider).to eq(provider)
        expect(interview.date_and_time).to eq(amended_date_and_time)
        expect(interview.location).to eq('Zoom call')
        expect(interview.additional_details).to eq('Business casual')
      end

      context 'if the interview is not changed' do
        let(:service_params) do
          {
            actor: provider_user,
            provider: interview.provider,
            interview: interview,
            date_and_time: interview.date_and_time,
            location: interview.location,
            additional_details: interview.additional_details,
          }
        end

        it 'an email is not sent', sidekiq: true do
          described_class.new(service_params).save!

          expect(ActionMailer::Base.deliveries.map { |d| d['rails-mail-template'].value }).not_to include('interview_updated')
        end
      end

      it 'creates an audit entry and sends an email', with_audited: true, sidekiq: true do
        described_class.new(service_params).save!

        associated_audit = application_choice.associated_audits.last
        expect(associated_audit.auditable).to eq(application_choice.interviews.first)
        expect(associated_audit.audited_changes.keys).to contain_exactly(
          'location',
          'date_and_time',
          'additional_details',
        )

        expect(associated_audit.audited_changes['location'].last).to eq('Zoom call')
        expect(associated_audit.audited_changes['additional_details'].last).to eq('Business casual')

        expect(ActionMailer::Base.deliveries.first['rails-mail-template'].value).to eq('interview_updated')
      end
    end
  end
end
