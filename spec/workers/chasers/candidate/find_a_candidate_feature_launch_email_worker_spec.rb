require 'rails_helper'

RSpec.describe Chasers::Candidate::FindACandidateFeatureLaunchEmailWorker do
  before do
    FeatureFlag.activate(:candidate_preferences)
  end

  describe '#perform' do
    it 'sends the find_a_candidate_feature_launch_email to applications that are eligible for the pool' do
      candidate = create_candidate_eligible_for_pool
      application_form = candidate.current_application

      expect {
        described_class.new.perform(application_form_ids: [application_form.id])
      }.to have_enqueued_job.on_queue('mailers')
                            .with('CandidateMailer', 'find_a_candidate_feature_launch_email', 'deliver_now', args: [application_form])
        .and change(ChaserSent, :count).from(0).to(1)
    end

    context 'when the candidate has already received the email' do
      it 'does not send the email again' do
        candidate = create_candidate_eligible_for_pool
        application_form = candidate.current_application
        create(:chaser_sent, chased: application_form, chaser_type: 'find_a_candidate_feature_launch')

        expect {
          described_class.new.perform(application_form_ids: [application_form.id])
        }.not_to have_enqueued_job.on_queue('mailers')
                              .with('CandidateMailer', 'find_a_candidate_feature_launch_email', 'deliver_now', args: [application_form])
      end
    end

    context 'when the candidate has opted out of marketing emails' do
      it 'does not send the email' do
        candidate = create_candidate_eligible_for_pool(unsubscribed_from_emails: true)
        application_form = candidate.current_application

        expect {
          described_class.new.perform(application_form_ids: [application_form.id])
        }.not_to have_enqueued_job.on_queue('mailers')
                                  .with('CandidateMailer', 'find_a_candidate_feature_launch_email', 'deliver_now', args: [application_form])
      end
    end

    context 'when the candidate is not eligible for pool' do
      it 'does not send the email' do
        application_form = create(:application_form)

        expect {
          described_class.new.perform(application_form_ids: [application_form.id])
        }.not_to have_enqueued_job.on_queue('mailers')
                                  .with('CandidateMailer', 'find_a_candidate_feature_launch_email', 'deliver_now', args: [application_form])
      end
    end

    context 'when the Application ID is not in the perform arguments' do
      it 'does not send the email' do
        candidate = create_candidate_eligible_for_pool
        application_form = candidate.current_application

        expect {
          described_class.new.perform(application_form_ids: [])
        }.not_to have_enqueued_job.on_queue('mailers')
                                  .with('CandidateMailer', 'find_a_candidate_feature_launch_email', 'deliver_now', args: [application_form])
      end
    end
  end

private

  def create_candidate_eligible_for_pool(**candidate_attributes)
    candidate = create(:candidate, **candidate_attributes)
    create(:application_choice, :rejected, candidate:)

    candidate
  end
end
