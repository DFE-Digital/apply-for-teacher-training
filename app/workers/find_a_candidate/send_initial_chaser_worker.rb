module FindACandidate
  class SendInitialChaserWorker < ApplicationJob
    def perform(invite_id)
      ActiveRecord::Base.transaction do
        invite = Pool::Invite.current_cycle.published.not_responded
                              .where.missing(:initial_pool_invite_chasers_sent)
                              .find_by(id: invite_id)

        if invite.present?
          CandidateMailer.initial_invite_chaser(invite).deliver_now

          ChaserSent.create!(chased: invite, chaser_type: 'initial_pool_invite')
        end
      end
    end
  end
end
