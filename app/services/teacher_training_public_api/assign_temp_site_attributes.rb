module TeacherTrainingPublicAPI
  class AssignTempSiteAttributes
    def initialize(site_from_api, provider)
      @site_from_api = site_from_api
      @provider = provider
    end

    def call
      assign_site_attributes
      site
    end

  private

    attr_reader :provider, :site_from_api

    def site
      @_site ||= provider.temp_sites.create_or_find_by(uuid: site_from_api.uuid) do |s|
        # We need to set the name and code here so that the record is valid when created.
        # If it is not valid, it just gets initialised (and is not persisted to the db). When calling save!, it
        # is possible for a duplicate record to have already been created by another sidekiq worker.
        s.name = site_from_api.name
        s.code = site_from_api.code
      end
    end

    def assign_site_attributes
      site.code = site_from_api.code
      site.name = site_from_api.name
      site.address_line1 = site_from_api.street_address_1&.strip
      site.address_line2 = site_from_api.street_address_2&.strip
      site.address_line3 = site_from_api.city&.strip
      site.address_line4 = site_from_api.county&.strip
      site.postcode = site_from_api.postcode&.strip
      site.region = site_from_api.region_code&.strip
      site.latitude = site_from_api.latitude
      site.longitude = site_from_api.longitude
    end
  end
end
