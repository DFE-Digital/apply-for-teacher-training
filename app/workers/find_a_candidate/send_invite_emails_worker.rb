class FindACandidate::SendInviteEmailsWorker
  include Sidekiq::Worker

  sidekiq_options queue: :default

  def perform
    grouped_pool_invites_to_be_sent = Pool::Invite
                                .published
                                .not_sent_to_candidate
                                .group_by(&:candidate)

    grouped_pool_invites_to_be_sent.each do |candidate, invites|
      ActiveRecord::Base.transaction do
        invites.each(&:sent_to_candidate!)
        CandidateMailer.candidate_invites(candidate, invites).deliver_later
      end
    end
  end
end
