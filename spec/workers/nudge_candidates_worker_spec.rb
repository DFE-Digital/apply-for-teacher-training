require 'rails_helper'

RSpec.describe NudgeCandidatesWorker, :sidekiq do
  describe '#perform' do
    let(:application_form_unstarted) { create(:application_form) }
    let(:application_form) { create(:completed_application_form) }
    let(:application_form_with_no_courses) { create(:application_form) }
    let(:application_form_with_no_personal_statement) { create(:application_form) }

    before do
      first_query = instance_double(
        GetIncompleteCourseChoiceApplicationsReadyToNudge,
        call: [application_form_with_no_courses],
      )
      second_query = instance_double(
        GetIncompletePersonalStatementApplicationsReadyToNudge,
        call: [application_form_with_no_personal_statement],
      )

      allow(GetIncompleteCourseChoiceApplicationsReadyToNudge).to receive(:new).and_return(first_query)
      allow(GetIncompletePersonalStatementApplicationsReadyToNudge).to receive(:new).and_return(second_query)
    end

    it 'sends email to candidates with zero course choices on their application' do
      described_class.new.perform

      email = email_for_candidate(application_form_with_no_courses.candidate)

      expect(email).to be_present
      expect(email.subject).to include(
        I18n.t!('candidate_mailer.nudge_unsubmitted_with_incomplete_courses.subject'),
      )
    end

    it 'sends email to candidates with incomplete personal statement on their application' do
      described_class.new.perform

      email = email_for_candidate(application_form_with_no_personal_statement.candidate)

      expect(email).to be_present
      expect(email.subject).to include(
        I18n.t!('candidate_mailer.nudge_unsubmitted_with_incomplete_personal_statement.subject'),
      )
    end
  end

  def email_for_candidate(candidate)
    ActionMailer::Base.deliveries.find { |email| email.header['to'].value == candidate.email_address }
  end
end
