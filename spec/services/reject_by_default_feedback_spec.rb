require 'rails_helper'

RSpec.describe RejectByDefaultFeedback, :continuous_applications do
  let(:application_choice) { create(:application_choice, :rejected_by_default) }
  let(:rejection_reason) { 'The course became full' }
  let(:actor) { create(:provider_user) }

  def service
    RejectByDefaultFeedback.new(
      actor:,
      application_choice:,
      rejection_reason:,
    )
  end

  it 'does not change application status' do
    expect { service.save }.not_to change(application_choice, :status)
  end

  it 'changes rejection_reason for the application choice' do
    expect { service.save }.to change(application_choice, :rejection_reason).to(rejection_reason)
    expect(application_choice.structured_rejection_reasons).to be_nil
    expect(application_choice.rejection_reasons_type).to eq('rejection_reason')
  end

  it 'changes structured_rejection_reasons for the application choice when provided with rejection reasons' do
    rejection_reasons_attrs = {
      selected_reasons: [
        { id: 'qualifications', label: 'Qualifications', selected_reasons: [
          { id: 'no_maths_gcse', label: 'No Maths GCSE' },
          { id: 'no_science_gcse', label: 'No Science GCSE' },
        ] },
        { id: 'course_full', label: 'Course full' },
      ],
    }

    service = described_class.new(
      actor:,
      application_choice:,
      structured_rejection_reasons: RejectionReasons.new(rejection_reasons_attrs),
    )
    service.save

    expect(application_choice.structured_rejection_reasons.deep_symbolize_keys).to eq(rejection_reasons_attrs)
    expect(application_choice.rejection_reason).to be_nil
    expect(application_choice.rejection_reasons_type).to eq('rejection_reasons')
  end

  it 'sets reject_by_default_feedback_sent_at' do
    expect { service.save }.to change(application_choice, :reject_by_default_feedback_sent_at).to(Time.zone.now)
  end

  it 'sends a Slack notification' do
    allow(SlackNotificationWorker).to receive(:perform_async)
    service.save
    expect(SlackNotificationWorker).to have_received(:perform_async)
  end
end
