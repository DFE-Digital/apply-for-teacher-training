class ProviderSetup
  def initialize(provider_user:)
    @provider_user = provider_user
  end

  def next_agreement_pending
    providers = @provider_user.providers
    pending_dsa_providers = providers.where.not(
      id: ProviderAgreement.data_sharing_agreements.for_provider(providers).select(:provider_id),
    )

    if pending_dsa_providers.present?
      ProviderAgreement.new(
        agreement_type: :data_sharing_agreement,
        provider: pending_dsa_providers.first,
        provider_user: @provider_user,
      )
    end
  end

  def next_relationship_pending
    permissions = ProviderRelationshipPermissions.find_by(
      setup_at: nil,
      training_provider: @provider_user.providers,
    )

    if permissions.present?
      auth = ProviderAuthorisation.new(actor: @provider_user)
      permissions if auth.can_manage_organisation?(provider: permissions.training_provider)
    end
  end
end
