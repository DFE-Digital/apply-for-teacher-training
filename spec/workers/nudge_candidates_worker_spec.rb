require 'rails_helper'

RSpec.describe NudgeCandidatesWorker, sidekiq: true do
  describe '#perform' do
    let(:application_form) { create(:completed_application_form) }

    before do
      query = instance_double(
        GetUnsubmittedApplicationsReadyToNudge,
        call: [application_form],
      )
      allow(GetUnsubmittedApplicationsReadyToNudge).to receive(:new).and_return(query)
    end

    context 'when the feature flag is active' do
      before { FeatureFlag.activate(:candidate_nudge_emails) }

      it 'sends email to candidates with an unsubmitted completed application' do
        described_class.new.perform

        email = email_for_candidate(application_form.candidate)

        expect(email).to be_present
        expect(email.subject).to include('Get last-minute advice about your teacher training application')
      end
    end

    context 'when the feature flag is inactive' do
      before { FeatureFlag.deactivate(:candidate_nudge_emails) }

      it 'does not send any emails to the candidate' do
        described_class.new.perform

        expect(email_for_candidate(application_form.candidate)).not_to be_present
      end
    end
  end

  def email_for_candidate(candidate)
    ActionMailer::Base.deliveries.find { |e| e.header['to'].value == candidate.email_address }
  end
end
