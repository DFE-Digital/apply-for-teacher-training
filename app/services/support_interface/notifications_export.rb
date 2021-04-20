module SupportInterface
  class NotificationsExport
    def data_for_export
      courses = Course.where(recruitment_cycle_year: RecruitmentCycle.current_year, open_on_apply: true)
      providers = Provider.includes(:provider_users, :application_choices).joins(:courses).merge(courses).group('providers.id')
      providers.find_each(batch_size: 100).flat_map do |provider|
        data_for_provider(provider, provider_users_with_make_decisions(provider), visible_applications(provider))
      end
    end

  private

    def data_for_provider(provider, users_with_make_decisions, applications)
      {
        provider_code: provider.code,
        provider_name: provider.name,
        applications_received: applications.count,
        applications_awaiting_decisions: awaiting_decisions_count(applications),
        applications_receiving_decisions: receiving_decisions_count(applications) - rbd_count(applications) - applications.count(&:withdrawn?),
        applications_rbd: rbd_count(applications),
        applications_withdrawn: applications.count(&:withdrawn?),
        number_of_provider_users: provider.provider_users.count,
        users_with_make_decisions: users_with_make_decisions.count,
        users_with_make_decisions_and_notifications_disabled: users_with_make_decisions.count { |u| !u.send_notifications },
        users_with_make_decisions_and_notifications_enabled: users_with_make_decisions.count(&:send_notifications),
      }
    end

    def provider_users_with_make_decisions(provider)
      provider.provider_permissions.includes(:provider_user).where(make_decisions: true).map(&:provider_user)
    end

    def visible_applications(provider)
      provider.application_choices.where(status: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER)
    end

    def awaiting_decisions_count(applications)
      applications.count(&:decision_pending?)
    end

    def receiving_decisions_count(applications)
      applications.count do |application|
        decision_receiving_states.include?(application.status.to_sym)
      end
    end

    def rbd_count(applications)
      applications.count { |a| a.rejected? && a.rejected_by_default? }
    end

    def decision_receiving_states
      ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER - ApplicationStateChange::DECISION_PENDING_STATUSES
    end
  end
end
