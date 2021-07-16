module TeacherTrainingPublicAPI
  class Provider < TeacherTrainingPublicAPI::Resource
    belongs_to :recruitment_cycle, param: :year
    has_many :courses

    def self.fetch(provider_code)
      where(year: ::RecruitmentCycle.current_year)
        .find(provider_code).first
    rescue JsonApiClient::Errors::NotFound
      nil
    rescue JsonApiClient::Errors::ServerError, JsonApiClient::Errors::ConnectionError => e
      Sentry.capture_exception(e)
      nil
    end
  end
end
