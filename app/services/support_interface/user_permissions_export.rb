module SupportInterface
  class UserPermissionsExport
    def data_for_export
      raw_data.map do |row|
        audited_changes = row[6]

        {
          date: row[0],
          user_id: row[1],
          user_name: row[2],
          provider_code: row[3],
          provider_name: row[4],
          user_whose_permissions_have_changed: row[5],
          permissions_added: permissions_changes(audited_changes),
          permissions_removed: permissions_changes(audited_changes, false),

        }
      end
    end

  private

    def permissions_changes(audited_changes, enabled = true)
      changes = audited_changes.select do |k, v|
        ProviderPermissions::VALID_PERMISSIONS.map(&:to_s).include?(k) &&
          (v.is_a?(Array) ? v.last == enabled : v == enabled)
      end

      changes.keys.sort.join(', ')
    end

    def permissions_clauses
      clauses = ProviderPermissions::VALID_PERMISSIONS.map do |p|
        "jsonb_exists(audits.audited_changes, '#{p}')"
      end

      clauses.join(' OR ')
    end

    def raw_data
      Audited::Audit
          .joins('JOIN provider_users_providers pup1 ON audits.auditable_id = pup1.id')
          .joins('JOIN provider_users ON pup1.provider_user_id = provider_users.id')
          .joins('LEFT JOIN provider_users_providers pup2 ON audits.user_id = pup2.provider_user_id')
          .joins('LEFT JOIN providers ON pup2.provider_id = providers.id')
          .where(auditable_type: 'ProviderPermissions')
          .where(action: %w[create update])
          .where(permissions_clauses)
          .pluck(
            'audits.created_at',
            'audits.user_id',
            Arel.sql(
              "CASE audits.user_type
              WHEN 'ProviderUser' THEN (SELECT CONCAT(first_name, ' ', last_name) FROM provider_users WHERE id = audits.user_id)
              WHEN 'SupportUser' THEN (SELECT CONCAT(first_name, ' ', last_name) FROM support_users WHERE id = audits.user_id)
            END".squish,
            ),
            'providers.code',
            'providers.name',
            Arel.sql("CONCAT(provider_users.first_name, ' ' , provider_users.last_name)"),
            'audits.audited_changes',
          )
    end
  end
end
