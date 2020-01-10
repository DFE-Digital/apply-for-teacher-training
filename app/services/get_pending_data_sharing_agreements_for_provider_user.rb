class GetPendingDataSharingAgreementsForProviderUser
  def self.call(provider_user:)
    providers = provider_user.providers
    no_dsa = providers.where.not(id: ProviderAgreement.data_sharing_agreements.for_provider(providers).select(:provider_id))
    no_dsa.map do |provider|
      ProviderAgreement.new(agreement_type: :data_sharing_agreement, provider: provider, provider_user: provider_user)
    end
  end
end
