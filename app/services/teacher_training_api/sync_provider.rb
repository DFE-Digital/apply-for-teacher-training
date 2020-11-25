module TeacherTrainingAPI
  class SyncProvider
    def self.call(provider_code:, provider_name: nil, provider_recruitment_cycle_year:, sync_courses: false, run_in_background: true)
      new(provider_code, provider_name, provider_recruitment_cycle_year, sync_courses).call(run_in_background: run_in_background)
    end

    attr_reader :provider_code, :provider_name, :provider_recruitment_cycle_year
    attr_accessor :provider

    def initialize(provider_code, provider_name, provider_recruitment_cycle_year, sync_courses)
      @provider_code = provider_code
      @provider_name = provider_name
      @provider_recruitment_cycle_year = provider_recruitment_cycle_year
      @sync_courses = sync_courses
    end

    def call(run_in_background: true)
      if sync_courses?
        provider_from_api = fetch_provider_from_teacher_training_api

        @provider = create_or_update_provider(
          base_provider_attrs.merge(
            provider_attrs_from(provider_from_api),
          ),
        )

        if run_in_background
          TeacherTrainingAPI::SyncCourses.perform_async(provider.id, provider_recruitment_cycle_year)
        else
          TeacherTrainingAPI::SyncCourses.new.perform(provider.id, provider_recruitment_cycle_year)
        end
      else
        @provider = create_or_update_provider(base_provider_attrs)
      end
    end

  private

    def sync_courses?
      @sync_courses || existing_provider&.sync_courses
    end

    def base_provider_attrs
      {
        sync_courses: sync_courses? || false,
        name: provider_name,
      }
    end

    def provider_attrs_from(provider_from_api)
      {
        region_code: provider_from_api.region_code&.strip,
        name: provider_from_api.name,
      }
    end

    def existing_provider
      ::Provider.find_by(code: provider_code)
    end

    def create_or_update_provider(attrs)
      # Prefer this to find_or_create_by as it results in 3x fewer audits
      if existing_provider
        existing_provider.update!(attrs)
      else
        new_provider = ::Provider.new(attrs.merge(code: provider_code)).save!
      end

      existing_provider || new_provider
    end

    def fetch_provider_from_find_api
      TeacherTrainingAPI::Provider
        .where(year: provider_recruitment_cycle_year)
        .find(provider_code)
        .first
    end
  end
end
