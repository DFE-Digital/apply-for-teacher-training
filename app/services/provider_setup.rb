class ProviderSetup
  def initialize(provider_user:)
    @provider_user = provider_user
  end

  def pending?
    next_agreement_pending || next_relationship_pending
  end

  def next_agreement_pending
    providers = @provider_user.providers.order(:created_at)
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
    relationships_pending&.first
  end

  def relationships_pending
    manageable_relationships.select do |relationship|
      (relationship.setup_at.blank? || relationship.invalid?) && relationship.providers_have_open_course?
    end
  end

private

  def manageable_relationships
    auth = ProviderAuthorisation.new(actor: @provider_user)
    auth.provider_relationships_that_actor_can_manage_organisations_for
  end
end
