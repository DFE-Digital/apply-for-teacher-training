class FindACandidate::SendInviteEmailsWorker
  include Sidekiq::Worker

  sidekiq_options queue: :default

  def perform
    pool_invites_to_be_sent = Pool::Invite
                                .published
                                .not_sent_to_candidate

    pool_invites_to_be_sent.find_each do |invite|
      ActiveRecord::Base.transaction do
        invite.sent_to_candidate!
        CandidateMailer.course_invite(invite).deliver_later
      end
    end
  end
end
