require 'rails_helper'

RSpec.describe NudgeCandidatesWorker, :sidekiq do
  describe '#perform' do
    context 'when all nudge feature flags are deactivated' do
      before do
        allow(GetIncompleteReferenceApplicationsReadyToNudge).to receive(:new)
        allow(GetIncompleteCourseChoiceApplicationsReadyToNudge).to receive(:new)
        allow(GetIncompletePersonalStatementApplicationsReadyToNudge).to receive(:new)
        allow(GetUnsubmittedApplicationsReadyToNudge).to receive(:new)
      end

      it 'skips over each nudge' do
        turn_off_all_nudges

        described_class.new.perform

        expect(GetIncompleteReferenceApplicationsReadyToNudge).not_to have_received(:new)
        expect(GetIncompleteCourseChoiceApplicationsReadyToNudge).not_to have_received(:new)
        expect(GetIncompletePersonalStatementApplicationsReadyToNudge).not_to have_received(:new)
        expect(GetUnsubmittedApplicationsReadyToNudge).not_to have_received(:new)
      end
    end

    context 'when individual nudge feature flags are activated' do
      it 'sends unsubmitted nudge' do
        turn_on_nudge(:unsubmitted_nudges)
        application_form = create(:completed_application_form)
        query = instance_double(GetUnsubmittedApplicationsReadyToNudge, call: [application_form])
        allow(GetUnsubmittedApplicationsReadyToNudge).to receive(:new).and_return(query)

        described_class.new.perform

        email = email_for_candidate(application_form.candidate)
        expect(email).to be_present
        expect(email.subject).to include(I18n.t!('candidate_mailer.nudge_unsubmitted.subject'))
      end

      it 'sends personal statement nudges' do
        turn_on_nudge(:personal_statement_nudges)
        application_form = create(:application_form)
        query = instance_double(GetIncompletePersonalStatementApplicationsReadyToNudge, call: [application_form])
        allow(GetIncompletePersonalStatementApplicationsReadyToNudge).to receive(:new).and_return(query)

        described_class.new.perform

        email = email_for_candidate(application_form.candidate)

        expect(email).to be_present
        expect(email.subject).to include(
          I18n.t!('candidate_mailer.nudge_unsubmitted_with_incomplete_personal_statement.subject'),
        )
      end

      it 'sends course choice nudges' do
        turn_on_nudge(:course_choice_nudges)
        application_form = create(:application_form)
        query = instance_double(GetIncompleteCourseChoiceApplicationsReadyToNudge, call: [application_form])
        allow(GetIncompleteCourseChoiceApplicationsReadyToNudge).to receive(:new).and_return(query)
        described_class.new.perform

        email = email_for_candidate(application_form.candidate)

        expect(email).to be_present
        expect(email.subject).to include(
          I18n.t!('candidate_mailer.nudge_unsubmitted_with_incomplete_courses.subject'),
        )
      end

      it 'sends reference nudges' do
        turn_on_nudge(:reference_nudges)
        application_form = create(:completed_application_form, submitted_at: nil, references_count: 0)
        query = instance_double(GetIncompleteReferenceApplicationsReadyToNudge, call: [application_form])
        allow(GetIncompleteReferenceApplicationsReadyToNudge).to receive(:new).and_return(query)
        described_class.new.perform

        email = email_for_candidate(application_form.candidate)

        expect(email).to be_present

        expect(email.subject).to include(I18n.t!('candidate_mailer.nudge_unsubmitted_with_incomplete_references.no_references.subject'))
      end
    end
  end

  def email_for_candidate(candidate)
    ActionMailer::Base.deliveries.find { |email| email.header['to'].value == candidate.email_address }
  end

  def turn_on_nudge(nudge_feature_flag)
    turn_off_all_nudges
    FeatureFlag.activate(nudge_feature_flag)
  end

  def turn_off_all_nudges
    %i[reference_nudges unsubmitted_nudges personal_statement_nudges course_choice_nudges].each do |nudge_feature_flag|
      FeatureFlag.deactivate(nudge_feature_flag)
    end
  end
end
