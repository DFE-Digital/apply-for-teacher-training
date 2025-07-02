module ProviderInterface
  class NotSeenCandidatesFilter < CandidatePoolFilter
    def save
      if valid? && filters.any?
        ActiveRecord::Base.transaction do
          provider_user_filter.update(filters:, updated_at: Time.zone.now)
          sister_filter.update(filters:, updated_at: 2.seconds.ago)
        end
      elsif remove_filters && filters.blank?
        ActiveRecord::Base.transaction do
          provider_user_filter.update(filters: {}, updated_at: Time.zone.now)
          sister_filter.update(filters: {}, updated_at: 2.seconds.ago)
        end
      end
    end

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
