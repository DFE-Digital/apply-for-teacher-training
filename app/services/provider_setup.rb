class ProviderSetup
  def initialize(provider_user:)
    @provider_user = provider_user
  end

  def next_relationship_pending
    permissions = ProviderInterface::TrainingProviderPermissions.find_by(
      setup_at: nil,
      training_provider: @provider_user.providers,
    )

    if permissions.present?
      auth = ProviderAuthorisation.new(actor: @provider_user)
      permissions if auth.can_manage_organisation?(provider: permissions.training_provider)
    end
  end
end
