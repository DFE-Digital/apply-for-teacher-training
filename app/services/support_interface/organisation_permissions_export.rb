module SupportInterface
  class OrganisationPermissionsExport
    def data_for_export
      data = Audited::Audit
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
          'audits.username',
          'ups.code',
          'ups.name',
          'tp.code',
          'tp.name',
          'rp.code',
          'rp.name',
          'audits.audited_changes',
        )

      data.map do |row|
        ratifying_provider_code, ratifying_provider_name, audited_changes = row.pop(3)
        row << permissions_changes(audited_changes, 'training')
        row << permissions_changes(audited_changes, 'training', false)
        row << ratifying_provider_code << ratifying_provider_name
        row << permissions_changes(audited_changes, 'ratifying')
        row << permissions_changes(audited_changes, 'ratifying', false)

        Hash[labels.zip(row)]
      end
    end

  private

    def labels
      [
        'Date',
        'User ID',
        'User making change',
        'Provider code',
        'Provider',
        'Training provider code',
        'Training provider',
        'Training provider permissions added',
        'Training provider permissions removed',
        'Ratifying provider code',
        'Ratifying provider',
        'Ratifying provider permissions added',
        'Ratifying provider permissions removed',
      ]
    end

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
  end
end
