module SupportInterface
  class ProvidersExport
    def providers
      relevant_providers.map do |provider|
        {
          name: provider.name,
          code: provider.code,
          agreement_accepted_at: provider.provider_agreements.where.not(accepted_at: nil).first&.accepted_at,
        }
      end
    end

  private

    def relevant_providers
      Provider
        .includes(
          :provider_agreements,
        )
        .where(sync_courses: true)
    end
  end
end
