module TeacherTrainingPublicAPI
  class SyncProvider
    def initialize(provider_from_api:, recruitment_cycle_year:, delay_by: nil)
      @provider_from_api = provider_from_api
      @recruitment_cycle_year = recruitment_cycle_year
      @delay_by = delay_by
    end

    def call(run_in_background: true)
      provider_attrs = provider_attrs_from(@provider_from_api)
      provider = create_or_update_provider(provider_attrs)
      sync_courses(run_in_background, provider)
    end

    def sync_courses(run_in_background, provider)
      if run_in_background
        TeacherTrainingPublicAPI::SyncCourses.perform_in(@delay_by, provider.id, @recruitment_cycle_year)
      else
        TeacherTrainingPublicAPI::SyncCourses.new.perform(provider.id, @recruitment_cycle_year, run_in_background: false)
      end
    end

  private

    def provider_attrs_from(provider_from_api)
      {
        sync_courses: true,
        region_code: provider_from_api.region_code&.strip,
        postcode: provider_from_api.postcode&.strip,
        name: provider_from_api.name,
        provider_type: provider_from_api.provider_type,
        latitude: provider_from_api.try(:latitude),
        longitude: provider_from_api.try(:longitude),
      }
    end

    def existing_provider
      ::Provider.find_by(code: @provider_from_api.code)
    end

    def create_or_update_provider(attrs)
      # Prefer this to find_or_create_by as it results in 3x fewer audits
      if existing_provider
        existing_provider.update!(attrs)

        existing_provider
      else
        ::Provider.create!(attrs.merge(code: @provider_from_api.code))
      end
    end
  end
end
