require 'rails_helper'

RSpec.describe CandidateInterface::ContinuousApplications::SubmitApplicationChoice, :continuous_applications do
  subject(:submit_application) { described_class.new(application_choice).call }

  let(:application_form) { application_choice.application_form }

  describe '#call' do
    context 'when application is already submitted' do
      let(:application_choice) { create(:application_choice, :awaiting_provider_decision) }

      it 'raises error' do
        expect {
          submit_application
        }.to raise_error(
          CandidateInterface::ContinuousApplications::ApplicationNotReadyToSendError,
          'Tried to send an application in the awaiting_provider_decision state to a provider',
        )
      end
    end

    context 'when application is unsubmitted' do
      let(:application_choice) { create(:application_choice, :unsubmitted) }

      it 'updates timestamps relevant to submitting an application' do
        travel_temporarily_to(Time.zone.local(0)) do
          submit_application
          expect(application_form.submitted_at).to eq Time.zone.local(0)
          expect(application_choice.sent_to_provider_at).to eq Time.zone.local(0)
        end
      end

      it 'updates inactive date for application' do
        travel_temporarily_to(Time.zone.local(2023, 10, 20)) do
          submit_application
          expect(application_choice.reject_by_default_at).to be_within(1.second).of(Time.zone.parse('01 Dec 2023 23:59:59 GMT'))
          expect(application_choice.reject_by_default_days).to eq 30
        end
      end

      it 'updates application choice status' do
        expect(application_choice).to be_unsubmitted
        submit_application
        expect(application_choice).to be_awaiting_provider_decision
      end

      it 'sets the personal_statement to the value of the application form becoming_a_teacher' do
        submit_application
        expect(application_choice.personal_statement).to eq application_form.becoming_a_teacher
      end
    end
  end
end
