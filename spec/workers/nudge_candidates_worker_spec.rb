require 'rails_helper'

RSpec.describe NudgeCandidatesWorker, sidekiq: true do
  describe '#perform' do
    let(:application_form) { create(:completed_application_form) }
    let(:application_form_with_no_courses) { create(:application_form) }

    before do
      query = instance_double(
        GetUnsubmittedApplicationsReadyToNudge,
        call: [application_form],
      )
      second_query = instance_double(
        GetIncompleteCourseChoiceApplicationsReadyToNudge,
        call: [application_form_with_no_courses],
      )
      allow(GetUnsubmittedApplicationsReadyToNudge).to receive(:new).and_return(query)
      allow(GetIncompleteCourseChoiceApplicationsReadyToNudge).to receive(:new).and_return(second_query)
    end

    context 'when the feature flag is active' do
      before do
        FeatureFlag.activate(:candidate_nudge_emails)
        FeatureFlag.activate(:candidate_nudge_course_choice_and_personal_statement)
      end

      it 'sends email to candidates with an unsubmitted completed application' do
        described_class.new.perform

        email = email_for_candidate(application_form.candidate)

        expect(email).to be_present
        expect(email.subject).to include('Get last-minute advice about your teacher training application')
      end

      it 'sends email to candidates with zero course choices on their application' do
        described_class.new.perform

        email = email_for_candidate(application_form_with_no_courses.candidate)

        expect(email).to be_present
        expect(email.subject).to include(
          I18n.t!('candidate_mailer.nudge_unsubmitted_with_incomplete_courses.subject'),
        )
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
