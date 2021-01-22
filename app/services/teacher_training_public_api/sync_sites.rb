module TeacherTrainingPublicAPI
  class SyncSites
    attr_reader :provider
    attr_reader :course

    include Sidekiq::Worker
    sidekiq_options retry: 3, queue: :low_priority

    def perform(provider_id, recruitment_cycle_year, course_id)
      @provider = ::Provider.find(provider_id)
      @course = ::Course.find(course_id)

      sites = TeacherTrainingPublicAPI::Site.where(
        year: recruitment_cycle_year,
        provider_code: @provider.code,
        course_code: @course.code
      ).includes(:site_status).paginate(per_page: 500)

      sites.each do |site_from_api|
        site = provider.sites.find_or_create_by(code: site_from_api.code)

        site.name = site_from_api.name
        site.address_line1 = site_from_api.street_address_1&.strip
        site.address_line2 = site_from_api.try(:street_address_2)&.strip
        site.address_line3 = site_from_api.try(:street_address_3)&.strip
        site.address_line4 = site_from_api.try(:street_address_4)&.strip
        site.postcode = site_from_api.postcode&.strip
        site.latitude = site_from_api.latitude
        site.longitude = site_from_api.longitude

        site_status = site_from_api.location_status

        site.save!

      end
    rescue JsonApiClient::Errors::ApiError
      raise TeacherTrainingPublicAPI::SyncError
    end

  private

  end
end
