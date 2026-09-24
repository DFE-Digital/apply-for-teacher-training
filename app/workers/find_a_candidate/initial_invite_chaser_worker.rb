module FindACandidate
  class InitialInviteChaserWorker < ApplicationJob
    def perform
      invites = Pool::Invite.current_cycle.published.not_responded
        .where.missing(:initial_pool_invite_chasers_sent)
        .where(
          application_form_id: Pool::Invite.current_cycle.published.not_responded
           .where.missing(:initial_pool_invite_chasers_sent)
           .where('sent_to_candidate_at <= ? ', 3.days.ago)
           .group(:application_form_id)
           .having('COUNT(*) < ?', Pool::Invite::NUMBER_OF_INVITES_TO_REMOVE_FROM_POOL)
           .select(:application_form_id),
        )
        .select(:id)

      # Should return 1 invite per application
      invites.each do |invite|
        SendInitialChaserWorker.perform_later(invite.id)
      end
    end
  end
end
