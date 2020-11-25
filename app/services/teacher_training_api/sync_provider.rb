module TeacherTrainingAPI
  class SyncProvider
    def initialize(provider_from_api:, recruitment_cycle_year:)
      @provider_from_api = provider_from_api
      @recruitment_cycle_year = recruitment_cycle_year
    end

    def call(run_in_background: false)
      provider = create_or_update_provider(
        provider_attrs_from(@provider_from_api),
      )

      if sync_courses?
        if run_in_background
          TeacherTrainingAPI::SyncCourses.perform_async(provider.id, @recruitment_cycle_year)
        else
          TeacherTrainingAPI::SyncCourses.new.perform(provider.id, @recruitment_cycle_year)
        end
      end
    end

  private

    def sync_courses?
      @sync_courses || existing_provider&.sync_courses
    end

    def provider_attrs_from(provider_from_api)
      {
        sync_courses: sync_courses? || false,
        region_code: provider_from_api.region_code&.strip,
        name: provider_from_api.name,
      }
    end

    def existing_provider
      ::Provider.find_by(code: @provider_from_api.code)
    end

    def create_or_update_provider(attrs)
      # Prefer this to find_or_create_by as it results in 3x fewer audits
      if existing_provider
        existing_provider.update!(attrs)
      else
        new_provider = ::Provider.new(attrs.merge(code: @provider_from_api.code)).save!
      end

      existing_provider || new_provider
    end
  end
end
