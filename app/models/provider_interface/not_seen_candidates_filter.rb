module ProviderInterface
  class NotSeenCandidatesFilter < CandidatePoolFilter
  private

    def build_provider_user_filter
      current_provider_user.find_a_candidate_not_seen_filter ||
        current_provider_user.build_find_a_candidate_not_seen_filter
    end

    def sister_filter
      current_provider_user.find_a_candidate_all_filter ||
        current_provider_user.build_find_a_candidate_all_filter
    end
  end
end
