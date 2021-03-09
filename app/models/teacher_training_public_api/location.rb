module TeacherTrainingPublicAPI
  class Location < TeacherTrainingPublicAPI::Resource
    belongs_to :recruitment_cycle, through: :provider, param: :year
    belongs_to :provider, param: :provider_code
    belongs_to :course, param: :course_code

    def full_address
      [street_address_1, street_address_2, city, county, postcode]
        .reject(&:blank?)
        .join(', ')
    end

    def self.fetch(provider_code, course_code)
      where(recruitment_cycle_year: RecruitmentCycle.current_year)
        .where(provider_code: provider_code)
        .where(course_code: course_code)
        .all
    rescue JsonApiClient::Errors::NotFound
      nil
    rescue JsonApiClient::Errors::ServerError, JsonApiClient::Errors::ConnectionError => e
      Raven.capture_exception(e)
      nil
    end
  end
end
