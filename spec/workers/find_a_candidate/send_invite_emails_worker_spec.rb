require 'rails_helper'

RSpec.describe FindACandidate::SendInviteEmailsWorker do
  describe '#perform' do
    it 'groups invites by candidate' do
      candidate = create(:candidate)
      _application_form = create(:application_form, :completed, candidate: candidate)
      invite1 = create(:pool_invite,
                       :published,
                       :not_sent_to_candidate,
                       candidate: candidate)
      invite2 = create(:pool_invite,
                       :published,
                       :not_sent_to_candidate,
                       candidate: candidate)

      expect {
        described_class.new.perform
      }.to have_enqueued_job.on_queue('mailers')
                            .with('CandidateMailer', 'candidate_invites', 'deliver_now', args: [candidate, [invite1, invite2]])
    end

    it 'does not send to draft invites' do
      candidate = create(:candidate)
      _application_form = create(:application_form, :completed, candidate: candidate)
      invite = create(:pool_invite,
                      :draft,
                      :not_sent_to_candidate,
                      candidate: candidate)

      expect {
        described_class.new.perform
      }.not_to have_enqueued_job.on_queue('mailers')
                       .with('CandidateMailer', 'candidate_invites', 'deliver_now', args: [candidate, [invite]])
      expect(invite.reload).not_to be_sent_to_candidate
    end

    it 'does not send emails to candidates who have already received them' do
      candidate = create(:candidate)
      _application_form = create(:application_form, :completed, candidate: candidate)
      invite = create(:pool_invite,
                      :published,
                      :sent_to_candidate,
                      candidate: candidate)

      expect {
        described_class.new.perform
      }.not_to have_enqueued_job.on_queue('mailers')
                       .with('CandidateMailer', 'candidate_invites', 'deliver_now', args: [candidate, [invite]])
      expect(invite.reload).to be_sent_to_candidate
    end
  end
end
