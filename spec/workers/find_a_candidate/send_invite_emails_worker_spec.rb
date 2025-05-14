require 'rails_helper'

RSpec.describe FindACandidate::SendInviteEmailsWorker do
  describe '#perform' do
    it 'sends invite emails to candidates' do
      application_form = create(:application_form, :completed)
      invite = create(:pool_invite,
                      :published,
                      :not_sent_to_candidate,
                      candidate: application_form.candidate)

      expect {
        described_class.new.perform
      }.to have_enqueued_job.on_queue('mailers')
                            .with('CandidateMailer', 'course_invite', 'deliver_now', args: [invite])

      expect(invite.reload).to be_sent_to_candidate
    end

    it 'does not send to draft invites' do
      application_form = create(:application_form, :completed)
      invite = create(:pool_invite,
                      :draft,
                      :not_sent_to_candidate,
                      candidate: application_form.candidate)

      expect {
        described_class.new.perform
      }.not_to have_enqueued_job.on_queue('mailers')
                            .with('CandidateMailer', 'course_invite', 'deliver_now', args: [invite])
      expect(invite.reload).not_to be_sent_to_candidate
    end

    it 'does not send emails to candidates who have already received them' do
      application_form = create(:application_form, :completed)
      invite = create(:pool_invite,
                      :published,
                      :sent_to_candidate,
                      candidate: application_form.candidate)

      expect {
        described_class.new.perform
      }.not_to have_enqueued_job.on_queue('mailers')
                                .with('CandidateMailer', 'course_invite', 'deliver_now', args: [invite])
      expect(invite.reload).to be_sent_to_candidate
    end
  end
end
