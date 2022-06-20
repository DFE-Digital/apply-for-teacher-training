module SupportInterface
  class SitesExport
    include GeocodeHelper

    def sites(*)
      relevant_sites.find_each(batch_size: 100).map do |site|
        {
          site_id: site.id,
          site_code: site.code,
          provider_code: site.provider.code,
          distance_from_provider: format_distance(site, site.provider, with_units: false),
          site_uuid: site.uuid,
          recruitment_cycle_year: site.course_options.first.course.recruitment_cycle_year,
        }
      end
    end

    alias data_for_export sites

  private

    def relevant_sites
      TempSite.joins(:course_options, :provider)
              .includes(:provider, course_options: [:course])
              .where(course_options: { site_still_valid: true })
              .order('providers.code ASC')
    end
  end
end
