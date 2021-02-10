module TeacherTrainingPublicAPI
  class Course < TeacherTrainingPublicAPI::Resource
    belongs_to :recruitment_cycle, through: :provider, param: :year
    belongs_to :provider, param: :provider_code
    has_many :locations

    def self.fetch(provider_code, course_code)
      where(recruitment_cycle_year: RecruitmentCycle.current_year)
        .where(provider_code: provider_code)
        .find(course_code)
        .first
    rescue JsonApiClient::Errors::NotFound
      nil
    rescue JsonApiClient::Errors::ServerError, JsonApiClient::Errors::ConnectionError => e
      Raven.capture_exception(e)
      nil
    end
  end
end
