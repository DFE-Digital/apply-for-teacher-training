require 'rails_helper'

RSpec.describe WithdrawApplication do
  include CourseOptionHelpers

  describe '#save!' do
    before do
      allow(ProviderMailer).to receive(:application_withdrawn).and_return(
        instance_double(ActionMailer::MessageDelivery, deliver_later: true),
      )
      allow(CandidateMailer).to receive(:withdraw_last_application_choice).and_return(
        instance_double(ActionMailer::MessageDelivery, deliver_later: true),
      )
      allow(CandidateCoursesRecommender).to receive(:recommended_courses_url)
                                              .and_return(recommended_courses_url)
    end

    let(:recommended_courses_url) { nil }

    it 'changes the state of the application_choice to "withdrawn"' do
      choice = create(:application_choice, status: :awaiting_provider_decision)

      described_class.new(application_choice: choice).save!

      choice.reload
      expect(choice.status).to eq 'withdrawn'
      expect(choice.withdrawn_or_declined_for_candidate_by_provider).to be false
    end

    it 'cancels upcoming interviews for the withdrawn application' do
      cancel_service = instance_double(CancelUpcomingInterviews, call!: true)
      withdrawing_application = create(:application_choice, status: :interviewing)
      allow(CancelUpcomingInterviews).to receive(:new)
                                           .with(
                                             actor: withdrawing_application.candidate,
                                             application_choice: withdrawing_application,
                                             cancellation_reason: 'You withdrew your application.',
                                           )
                                           .and_return(cancel_service)

      described_class.new(application_choice: withdrawing_application).save!

      expect(cancel_service).to have_received(:call!)
    end

    it 'sends a notification email to the training provider and ratifying provider' do
      training_provider = create(:provider)
      training_provider_user = create(:provider_user, :with_notifications_enabled, providers: [training_provider])

      ratifying_provider = create(:provider)
      ratifying_provider_user = create(:provider_user, :with_notifications_enabled, providers: [ratifying_provider])

      course_option = course_option_for_accredited_provider(provider: training_provider, accredited_provider: ratifying_provider)
      application_form = create(:application_form)
      application_choice = create(:application_choice,
                                  :awaiting_provider_decision,
                                  course_option:,
                                  application_form:)

      described_class.new(application_choice:).save!

      expect(CandidateMailer).to have_received(:withdraw_last_application_choice)
                                   .with(application_form, nil)
      expect(ProviderMailer).to have_received(:application_withdrawn)
                                  .with(training_provider_user, application_choice, 0)
      expect(ProviderMailer).to have_received(:application_withdrawn)
                                  .with(ratifying_provider_user, application_choice, 0)
    end

    context 'with a course recommendation url' do
      let(:recommended_courses_url) { 'https://www.find-postgraduate-teacher-training.service.gov.uk/results' }

      it 'sends an email to the candidate with a recommendation url' do
        application_form = create(:application_form)
        application_choice = create(:application_choice,
                                    :awaiting_provider_decision,
                                    application_form:)

        described_class.new(application_choice:).save!

        expect(CandidateMailer).to have_received(:withdraw_last_application_choice)
                                     .with(application_form, 'https://www.find-postgraduate-teacher-training.service.gov.uk/results')
      end
    end

    context 'when the candidate has other applications' do
      it 'does not send the withdraw_last_application_choice email' do
        application_form = create(:application_form)
        application_choice = create(:application_choice, :awaiting_provider_decision, application_form:)
        _other_application_choice = create(:application_choice, :awaiting_provider_decision, application_form:)

        described_class.new(application_choice:).save!

        expect(CandidateMailer).not_to have_received(:withdraw_last_application_choice)
      end
    end
  end
end
