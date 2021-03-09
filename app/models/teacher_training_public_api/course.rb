module TeacherTrainingPublicAPI
  class Course < TeacherTrainingPublicAPI::Resource
    # a hack to keep this attribute on a course returned by #fetch, even though
    # it's not provided by the API. We need it so we can pretend to be an
    # ordinary course out of the database when rendering the apply-from-find page.
    attr_accessor :provider_code

    belongs_to :recruitment_cycle, through: :provider, param: :year
    belongs_to :provider, param: :provider_code
    has_many :locations

    def name_and_code
      "#{name} (#{code})"
    end

    # this needs to behave interchangeably with a course in the database
    # once it gets to the apply-from-find views, so provide a provider.code
    # interface like "proper" courses have. This is like what we did in FindAPI.
    def provider
      Struct.new(:code).new(provider_code)
    end

    def sites
      @sites_cache ||= Location.where(
        year: ::RecruitmentCycle.current_year,
        provider_code: provider_code,
        course_code: code,
      ).includes(:location_status).paginate(per_page: 500).all
    end

    def self.fetch(provider_code, course_code)
      course = where(year: ::RecruitmentCycle.current_year)
        .where(provider_code: provider_code)
        .find(course_code).first

      course.provider_code = provider_code
      course
    rescue JsonApiClient::Errors::NotFound
      nil
    rescue JsonApiClient::Errors::ServerError, JsonApiClient::Errors::ConnectionError => e
      Raven.capture_exception(e)
      nil
    end
  end
end
