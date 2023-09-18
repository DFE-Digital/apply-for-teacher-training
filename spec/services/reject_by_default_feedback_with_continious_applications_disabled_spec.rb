# This file can be deleted with the continuous applications feature flag. The remaining functionality is tested in
# 'reject_by_default_feedback_spec.rb'

require 'rails_helper'

RSpec.describe RejectByDefaultFeedback, :sidekiq, continuous_applications: false do
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

  it 'sends an email to the candidate' do
    service.save

    expect(CandidateMailer.deliveries.count).to be 1
  end

  context 'candidate did not get a place on any of their courses and has not applied again since' do
    it "requests mailer to display 'apply again' guidance" do
      show_apply_again_guidance = true
      mailer = instance_double(ActionMailer::MessageDelivery, deliver_later: true)

      allow(CandidateMailer).to receive(:feedback_received_for_application_rejected_by_default).and_return(mailer)

      service.save

      expect(CandidateMailer).to have_received(:feedback_received_for_application_rejected_by_default).with(application_choice, show_apply_again_guidance)
    end
  end

  context 'candidate did get a place on one of their courses' do
    it "does not request mailer to display 'apply again' guidance" do
      show_apply_again_guidance = false
      mailer = instance_double(ActionMailer::MessageDelivery, deliver_later: true)

      create(:application_choice, :offered, application_form: application_choice.application_form)
      allow(CandidateMailer).to receive(:feedback_received_for_application_rejected_by_default).and_return(mailer)

      service.save

      expect(CandidateMailer).to have_received(:feedback_received_for_application_rejected_by_default).with(application_choice, show_apply_again_guidance)
    end
  end

  context 'candidate did not get a place on any of their courses but has applied again since' do
    it "does not request mailer to display 'apply again' guidance" do
      show_apply_again_guidance = false
      mailer = instance_double(ActionMailer::MessageDelivery, deliver_later: true)

      create(:application_form, :minimum_info, phase: 'apply_2', previous_application_form_id: application_choice.application_form.id, candidate_id: application_choice.application_form.candidate_id)
      allow(CandidateMailer).to receive(:feedback_received_for_application_rejected_by_default).and_return(mailer)

      service.save

      expect(CandidateMailer).to have_received(:feedback_received_for_application_rejected_by_default).with(application_choice, show_apply_again_guidance)
    end
  end

  it 'sends a Slack notification' do
    allow(SlackNotificationWorker).to receive(:perform_async)
    service.save
    expect(SlackNotificationWorker).to have_received(:perform_async)
  end
end
