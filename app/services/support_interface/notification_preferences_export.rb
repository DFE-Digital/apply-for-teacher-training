module SupportInterface
  class NotificationPreferencesExport
    LABELS = %i[
      provider_user_id
      provider_code
      permissions_make_decisions
      changed_at
      notifications_added
      notifications_removed
    ].freeze

    def data_for_export
      rows = Audited::Audit
        .where(auditable_type: 'ProviderUserNotificationPreferences', action: 'update')
        .joins('JOIN provider_user_notifications ON auditable_id = provider_user_notifications.id')
        .joins('JOIN provider_users ON provider_user_notifications.provider_user_id = provider_users.id')
        .joins('JOIN provider_users_providers ON provider_users.id = provider_users_providers.provider_user_id')
        .joins('JOIN providers ON providers.id = provider_users_providers.provider_id')
        .order(:created_at)
        .pluck(
          'provider_users.id',
          'providers.code',
          'provider_users_providers.make_decisions',
          'audits.created_at',
          'audits.audited_changes',
        )

      rows.map do |row|
        notifications_added, notifications_removed = group_audit_changes(row.pop)
        row[3] = row[3].iso8601
        row << notifications_added << notifications_removed
        Hash[LABELS.zip(row)]
      end
    end

  private

    def group_audit_changes(changes)
      changes.partition { |_, v| v == [false, true] }.map { |ary| ary.map(&:first).sort.join(', ') }
    end
  end
end
