module Pool::Candidates
  def self.for_provider(provider:)
    dismissed_candidates = Candidate.joins(:pool_dismissals).where(pool_dismissals: { provider: provider })

    Candidate
      # .for_current_cycle
      .pool_status_opt_in
      .excluding(dismissed_candidates)
      # .where_eligible_for_pool # this still needs definition - is it only rejected/withdrawn candidates?
      .joins("LEFT OUTER JOIN pool_invites on pool_invites.candidate_id = candidates.id and pool_invites.provider_id = #{provider.id}")
      .distinct
      .select('candidates.*, case when pool_invites.id is null then false else true end as invited')
  end
end
