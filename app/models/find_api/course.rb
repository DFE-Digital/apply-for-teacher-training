module FindAPI
  class Course < JsonApiClient::Resource
    self.site = 'https://bat-qa-mcbe-as.azurewebsites.net/api/v3/'

    belongs_to :recruitment_cycle, through: :provider, param: :recruitment_cycle_year
    belongs_to :provider, param: :provider_code

    property :name, type: :string

    def self.fetch(provider_code, course_code)
      where(recruitment_cycle_year: '2020')
        .where(provider_code: provider_code)
        .find(course_code)
        .first
    rescue JsonApiClient::Errors::NotFound
      nil
    rescue JsonApiClient::Errors::ServerError
      new provider_code: provider_code, course_code: course_code
    end
  end
end
