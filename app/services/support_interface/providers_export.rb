module SupportInterface
  class ProvidersExport
    include GeocodeHelper

    def providers
      relevant_providers.find_each(batch_size: 100).map do |provider|
        {
          provider_name: provider.name,
          provider_code: provider.code,
          agreement_accepted_at: provider.provider_agreements.where.not(accepted_at: nil).first&.accepted_at,
          average_distance_to_site: average_distance_to_site(provider),
        }
      end
    end

    alias data_for_export providers

  private

    def relevant_providers
      Provider
        .includes(
          :provider_agreements,
          :sites,
        )
        .order(:name)
    end

    def average_distance_to_site(provider)
      format_average_distance(
        provider,
        provider.sites,
        with_units: false,
      )
    end
  end
end
