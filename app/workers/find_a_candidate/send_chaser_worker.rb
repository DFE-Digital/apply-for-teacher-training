module FindACandidate
  class SendChaserWorker
    include Sidekiq::Worker

    sidekiq_options queue: :default

    def perform(invite_ids)
      ActiveRecord::Base.transaction do
        invites = Pool::Invite.current_cycle.published.not_responded
          .where.missing(:chasers_sent)
          .where(id: invite_ids)

        if invites.present?
          CandidateMailer.invites_chaser(invites).deliver_now

          invites.each do |invite|
            ChaserSent.create!(chased: invite, chaser_type: 'pool_invite')
          end
        end
      end
    end
  end
end
