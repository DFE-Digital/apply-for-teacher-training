module SupportInterface
  class ProviderOnboardingMonitor
    include ApplicationHelper

    def providers_with_no_users
      @providers_with_no_users ||= target_providers.where.not(id: providers_with_users.select(:id))
    end

    def providers_where_no_user_has_logged_in
      @providers_where_no_user_has_logged_in ||= providers_with_users
                                                   .select('providers.*, MAX(provider_users.last_signed_in_at)')
                                                   .group('providers.id')
                                                   .having('MAX(provider_users.last_signed_in_at) IS NULL')
    end

    def permissions_not_set_up
      @permissions_not_set_up ||= ProviderRelationshipPermissions
                                    .providers_with_current_cycle_course
                                    .where(setup_at: nil)
    end

    def no_decisions_in_last_7_days
      @no_decisions_in_last_7_days ||= target_providers
                                         .select('providers.*, MAX(last_decisions.last_decision) as last_decision')
                                         .joins("INNER JOIN (#{applications_with_last_decision_sql}) as last_decisions ON providers.id = ANY(last_decisions.provider_ids)")
                                         .group('providers.id')
                                         .having("MAX(last_decisions.last_decision) < ('#{pg_now}'::TIMESTAMPTZ - interval '7 days') OR MAX(last_decisions.last_decision) IS NULL")
    end

  private

    def target_providers
      Provider.joins(:courses).merge(Course.current_cycle).distinct
    end

    def providers_with_users
      @providers_with_users ||= target_providers.joins(:provider_users).distinct
    end

    def applications_with_last_decision_sql
      provider_decision_timestamps = %w[
        rejected_at
        offered_at
        offer_changed_at
        offer_withdrawn_at
        offer_deferred_at
        conditions_not_met_at
        recruited_at
      ].join(',')

      ApplicationChoice
        .select('provider_ids', "CASE WHEN rejected_by_default THEN NULL ELSE GREATEST(#{provider_decision_timestamps}) END as last_decision")
        .to_sql
    end
  end
end
