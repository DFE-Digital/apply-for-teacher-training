module SupportInterface
  class ProvidersExport
    include GeocodeHelper

    def data_for_export(run_once_flag = false)
      relevant_providers.map do |provider|
        {
          'name' => provider.name,
          'code' => provider.code,
          'agreement_accepted_at' => provider.provider_agreements.where.not(accepted_at: nil).first&.accepted_at,
          'Average distance to site' => average_distance_to_site(provider),
        }
      end
      break if run_once_flag
    end

    # alias_method :data_for_export, :providers

  private

    def relevant_providers
      Provider
        .includes(
          :provider_agreements,
          :sites,
        )
        .where(sync_courses: true)
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
