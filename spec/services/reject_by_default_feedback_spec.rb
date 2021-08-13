require 'rails_helper'

RSpec.describe RejectByDefaultFeedback, sidekiq: true do
  let(:application_choice) { create(:application_choice, :with_rejection_by_default) }
  let(:rejection_reason) { 'The course became full' }
  let(:actor) { create(:provider_user) }

  def service
    RejectByDefaultFeedback.new(
      actor: actor,
      application_choice: application_choice,
      rejection_reason: rejection_reason,
    )
  end

  it 'does not change application status' do
    expect { service.save }.not_to change(application_choice, :status)
  end

  it 'changes rejection_reason for the application choice' do
    expect { service.save }.to change(application_choice, :rejection_reason).to(rejection_reason)
    expect(application_choice.structured_rejection_reasons).to eq nil
  end

  it 'changes structured_rejection_reasons for the application choice when provided' do
    reasons_for_rejection_attrs = {
      candidate_behaviour_y_n: 'Yes',
      candidate_behaviour_what_did_the_candidate_do: %w[other],
      candidate_behaviour_other: 'Bad language',
      candidate_behaviour_what_to_improve: 'Do not swear',
    }
    service = described_class.new(
      actor: actor,
      application_choice: application_choice,
      structured_rejection_reasons: ReasonsForRejection.new(reasons_for_rejection_attrs),
    )
    service.save

    expect(application_choice.structured_rejection_reasons.symbolize_keys).to eq(reasons_for_rejection_attrs)
    expect(application_choice.rejection_reason).to eq nil
  end

  it 'sets reject_by_default_feedback_sent_at' do
    Timecop.freeze do
      expect { service.save }.to change(application_choice, :reject_by_default_feedback_sent_at).to(Time.zone.now)
    end
  end

  it 'sends an email to the candidate' do
    service.save

    expect(CandidateMailer.deliveries.count).to be 1
  end

  it 'sends a Slack notification' do
    allow(SlackNotificationWorker).to receive(:perform_async)
    service.save
    expect(SlackNotificationWorker).to have_received(:perform_async)
  end
end
