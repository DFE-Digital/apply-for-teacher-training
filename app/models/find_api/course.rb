module FindAPI
  class Course < FindAPI::Resource
    belongs_to :recruitment_cycle, through: :provider, param: :recruitment_cycle_year
    belongs_to :provider, param: :provider_code

    def provider
      Provider.new(code: provider_code)
    end

    def code
      course_code
    end

    def name_and_code
      "#{name} (#{code})"
    end

    def self.fetch(provider_code, course_code)
      where(recruitment_cycle_year: RECRUITMENT_CYCLE_YEAR)
        .where(provider_code: provider_code)
        .find(course_code)
        .first
    rescue JsonApiClient::Errors::ServerError, JsonApiClient::Errors::ConnectionError => e
      Raven.capture_exception(e)
      nil
    rescue JsonApiClient::Errors::NotFound
      nil
    end
  end
end
