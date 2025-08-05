module DataMigrations
  class MigrateCandidateDecisionOnPoolInvites
    TIMESTAMP = 20250805125222
    MANUAL_RUN = false

    def change
      Pool::Invite.applied.update_all(candidate_decision: 'accepted')
    end
  end
end
