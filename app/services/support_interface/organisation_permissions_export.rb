module SupportInterface
  class OrganisationPermissionsExport
    def data_for_export
      raw_data.map do |row|
        audited_changes = row[9]

        {
          date: row[0],
          user_id: row[1],
          user_name: row[2],
          provider_code: row[3],
          provider_name: row[4],

          training_provider_code: row[5],
          training_provider_name: row[6],
          training_provider_permissions_added: permissions_changes(audited_changes, 'training'),
          training_provider_permissions_permissions_removed: permissions_changes(audited_changes, 'training', false),

          ratifying_provider_code: row[7],
          ratifying_provider_name: row[8],
          ratifying_provider_permissions_added: permissions_changes(audited_changes, 'ratifying'),
          ratifying_provider_permissions_permissions_removed: permissions_changes(audited_changes, 'ratifying', false),
        }
      end
    end

  private

    def permissions_changes(audited_changes, provider_type, enabled = true)
      permissions_attr_names = ProviderRelationshipPermissions::PERMISSIONS.map { |p| "#{provider_type}_provider_can_#{p}" }
      changes = audited_changes.select do |k, v|
        permissions_attr_names.include?(k) && (v.is_a?(Array) ? v.last == enabled : v == enabled)
      end

      changes.keys.map { |k| k.sub(/^(training_provider_can_|ratifying_provider_can_)/, '') }.join(', ')
    end

    def permissions_clauses
      clauses = ProviderRelationshipPermissions::PERMISSIONS.map do |p|
        [
          "jsonb_exists(audits.audited_changes, 'training_provider_can_#{p}')",
          "jsonb_exists(audits.audited_changes, 'ratifying_provider_can_#{p}')",
        ].join(' OR ')
      end

      clauses.join(' OR ')
    end

    def raw_data
      Audited::Audit
          .joins('INNER JOIN provider_relationship_permissions prp ON audits.auditable_id = prp.id')
          .joins('INNER JOIN providers tp ON prp.training_provider_id = tp.id')
          .joins('INNER JOIN providers rp ON prp.ratifying_provider_id = rp.id')
          .joins('LEFT JOIN provider_users_providers pup ON audits.user_id = pup.provider_user_id')
          .joins('LEFT JOIN providers ups ON pup.provider_id = ups.id')
          .where(auditable_type: 'ProviderRelationshipPermissions')
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
            'ups.code',
            'ups.name',
            'tp.code',
            'tp.name',
            'rp.code',
            'rp.name',
            'audits.audited_changes',
          )
    end
  end
end
