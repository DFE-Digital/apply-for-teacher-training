require 'rails_helper'

RSpec.describe SaveAndSendRejectByDefaultFeedback, sidekiq: true do
  let(:application_choice) { create(:application_choice, :with_rejection_by_default) }
  let(:rejection_reason) { 'The course became full' }
  let(:actor) { create(:provider_user) }

  def service
    SaveAndSendRejectByDefaultFeedback.new(
      actor: actor,
      application_choice: application_choice,
      rejection_reason: rejection_reason,
    )
  end

  it 'does not change application status' do
    expect { service.call! }.not_to change(application_choice, :status)
  end

  it 'changes rejection_reason for the application choice' do
    expect { service.call! }.to change(application_choice, :rejection_reason).to(rejection_reason)
  end

  it 'sets reject_by_default_feedback_sent_at' do
    Timecop.freeze do
      expect { service.call! }.to change(application_choice, :reject_by_default_feedback_sent_at).to(Time.zone.now)
    end
  end

  it 'sends an email to the candidate' do
    service.call!

    expect(CandidateMailer.deliveries.count).to be 1
  end

  it 'sends a Slack notification' do
    allow(SlackNotificationWorker).to receive(:perform_async)
    service.call!
    expect(SlackNotificationWorker).to have_received(:perform_async)
  end
end
