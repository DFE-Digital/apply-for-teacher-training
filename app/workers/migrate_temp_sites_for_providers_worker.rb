class MigrateTempSitesForProvidersWorker
  include Sidekiq::Worker

  def perform(provider_id, year)
    @provider = Provider.find(provider_id)

    migrate_temp_sites_for_courses(@provider, year)
  end

private

  def migrate_temp_sites_for_courses(provider, year)
    courses_from_api = TeacherTrainingPublicAPI::Course.where(
      year: year,
      provider_code: provider.code,
    ).paginate(per_page: 500)

    courses_from_api.each do |course_from_api|
      migrate_temp_sites_for_course(provider, course_from_api, year)
    end
  rescue JsonApiClient::Errors::ApiError
    nil
  end

  def migrate_temp_sites_for_course(provider, course_from_api, year)
    sites_from_api = TeacherTrainingPublicAPI::Location.where(
      year: year,
      provider_code: provider.code,
      course_code: course_from_api.code,
    ).includes(:location_status).paginate(per_page: 500)

    sites_from_api.each do |site_from_api|
      temp_site = if site_from_api.uuid.present?
                    TeacherTrainingPublicAPI::AssignTempSiteAttributes.new(site_from_api, provider).call
                  else
                    initialize_with_generated_uuid(site_from_api, provider)
                  end
      temp_site.save!

      attach_to_course_options(site_from_api.code, temp_site, Course.find_by(code: course_from_api.code))
    end
  rescue JsonApiClient::Errors::ApiError
    nil
  end

  def initialize_with_generated_uuid(site_from_api, provider)
    TempSite.new(
      uuid: SecureRandom.uuid,
      uuid_generated_by_apply: true,
      name: site_from_api.name,
      code: site_from_api.code,
      provider: provider,
      address_line1: site_from_api.street_address_1&.strip,
      address_line2: site_from_api.street_address_2&.strip,
      address_line3: site_from_api.city&.strip,
      address_line4: site_from_api.county&.strip,
      postcode: site_from_api.postcode&.strip,
      region: site_from_api.region_code&.strip,
      latitude: site_from_api.latitude,
      longitude: site_from_api.longitude,
    )
  end

  def attach_to_course_options(site_code, temp_site, course)
    return if course.blank?

    CourseOption.joins(:site).where(sites: { code: site_code }).where(course_id: course.id).each do |course_option|
      course_option.update(temp_site: temp_site)
    end
  end
end
