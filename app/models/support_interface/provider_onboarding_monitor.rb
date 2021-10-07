module SupportInterface
  class ProviderOnboardingMonitor
    def providers_with_no_users
      Provider.where.not(id: providers_with_users.select(:id))
    end

    def providers_where_no_user_has_logged_in
      Provider.where.not(id: providers_with_users_that_have_logged_in.select(:id))
    end

    def permissions_not_set_up
      providers_that_need_to_set_up_permissions = ProviderRelationshipPermissions
                                                    .providers_have_open_course
                                                    .where(setup_at: nil)
                                                    .pluck(:ratifying_provider_id, :training_provider_id)
                                                    .flatten
                                                    .uniq

      providers_with_users_that_have_logged_in.where(id: providers_that_need_to_set_up_permissions)
    end

    def no_decisions_in_last_7_days
      Provider
        .select('providers.*, MAX(last_decisions.last_decision) as last_decision')
        .joins("INNER JOIN (#{applications_with_last_decision_sql}) as last_decisions ON providers.id = ANY(last_decisions.provider_ids)")
        .group('providers.id')
        .having("MAX(last_decisions.last_decision) < now() - interval '7 days' OR MAX(last_decisions.last_decision) IS NULL")
    end

  private

    def providers_with_users
      Provider.joins(:provider_users).distinct
    end

    def providers_with_users_that_have_logged_in
      providers_with_users
        .where.not(provider_users: { last_signed_in_at: nil })
    end

    def applications_with_last_decision_sql
      ApplicationChoice
        .select('provider_ids', 'CASE WHEN rejected_by_default THEN NULL ELSE GREATEST(offered_at, rejected_at) END as last_decision')
        .to_sql
    end
  end
end
