module FindACandidate
  class PoolInviteChaserWorker
    include Sidekiq::Worker

    sidekiq_options queue: :default

    def perform
      invites = Pool::Invite.current_cycle.published.not_responded
        .where.missing(:chasers_sent)
        .where(
          application_form_id: Pool::Invite.current_cycle.published.not_responded
            .where.missing(:chasers_sent)
            .where('sent_to_candidate_at <= ? ', 1.day.ago)
            .group(:application_form_id)
            .having('COUNT(*) >= ?', Pool::Invite::NUMBER_OF_INVITES_TO_REMOVE_FROM_POOL)
            .select(:application_form_id),
        )
      .select(:id, :application_form_id)

      invites.group_by(&:application_form_id).each_value do |grouped_invites|
        SendChaserWorker.perform_async(grouped_invites.map(&:id))
      end
    end
  end
end
