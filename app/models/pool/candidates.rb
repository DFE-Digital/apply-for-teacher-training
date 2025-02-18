module Pool::Candidates
  def self.for_provider(providers:)
    # accept multiple providers
    # Don't show candidates rejected by the providers passed in here
    # just pass provider ids?

    dismissed_candidates = Candidate.joins(:pool_dismissals).where(pool_dismissals: { provider: providers })

    rejected_candidate_ids = ApplicationForm.current_cycle.rejected_and_not_accepted.pluck(:candidate_id).uniq

    Candidate
      .where(id: rejected_candidate_ids)
      .pool_status_opt_in
      # .for_current_cycle
      .excluding(dismissed_candidates)
      # .where_eligible_for_pool # this still needs definition - is it only rejected/withdrawn candidates?
    #  .joins("LEFT OUTER JOIN pool_invites on pool_invites.candidate_id = candidates.id and pool_invites.provider_id = #{provider.id}")
    #  .distinct don't think we need distinct
    #  .select('candidates.*, case when pool_invites.id is null then false else true end as invited')
    #
  end
end
