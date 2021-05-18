module TeacherTrainingPublicAPI
  class SyncProvider
    def initialize(provider_from_api:, recruitment_cycle_year:)
      @provider_from_api = provider_from_api
      @recruitment_cycle_year = recruitment_cycle_year
    end

    def call(run_in_background: true, force_sync_courses: false, incremental_sync: true)
      @force_sync_courses = force_sync_courses

      provider_attrs = if existing_provider
                         provider_attrs_from(@provider_from_api)
                       else
                         provider_attrs_from(@provider_from_api).merge(
                           sync_courses: force_sync_courses,
                         )
                       end

      provider = create_or_update_provider(provider_attrs)
      sync_courses(run_in_background, provider, incremental_sync: incremental_sync)
    end

    def sync_courses(run_in_background, provider, incremental_sync: true)
      if sync_courses?
        if run_in_background
          TeacherTrainingPublicAPI::SyncCourses.perform_async(provider.id, @recruitment_cycle_year, incremental_sync)
        else
          TeacherTrainingPublicAPI::SyncCourses.new.perform(provider.id, @recruitment_cycle_year, incremental_sync, run_in_background: false)
        end
      end
    end

  private

    def sync_courses?
      @force_sync_courses || existing_provider&.sync_courses
    end

    def provider_attrs_from(provider_from_api)
      {
        sync_courses: sync_courses?,
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
