module TeacherTrainingPublicAPI
  class SyncProvider
    def initialize(provider_from_api:, recruitment_cycle_year:, delay_by: nil, incremental_sync: true)
      @provider_from_api = provider_from_api
      @recruitment_cycle_year = recruitment_cycle_year
      @delay_by = delay_by
      @incremental_sync = incremental_sync
      @updates = {}
    end

    def call(run_in_background: true)
      provider_attrs = provider_attrs_from(@provider_from_api)
      provider = create_or_update_provider(provider_attrs)
      sync_courses(run_in_background, provider)
    end

    def sync_courses(run_in_background, provider)
      if run_in_background
        TeacherTrainingPublicAPI::SyncCourses.perform_in(@delay_by, provider.id, @recruitment_cycle_year, @incremental_sync)
      else
        TeacherTrainingPublicAPI::SyncCourses.new.perform(provider.id, @recruitment_cycle_year, @incremental_sync, run_in_background: false)
      end
    end

  private

    def provider_attrs_from(provider_from_api)
      {
        region_code: provider_from_api.region_code&.strip,
        postcode: provider_from_api.postcode&.strip,
        name: provider_from_api.name,
        phone_number: provider_from_api.telephone,
        email_address: provider_from_api.email,
        provider_type: provider_from_api.provider_type,
        latitude: provider_from_api.try(:latitude),
        longitude: provider_from_api.try(:longitude),
        selectable_school: provider_from_api.selectable_school,
      }
    end

    def existing_provider
      @existing_provider ||= ::Provider.find_by(code: @provider_from_api.code)
    end

    def create_or_update_provider(attrs)
      # Prefer this to find_or_create_by as it results in 3x fewer audits
      if existing_provider
        existing_provider.assign_attributes(attrs)

        @updates.merge!(providers: true) if !@incremental_sync && existing_provider.changed?

        existing_provider.save!
        existing_provider
      else
        provider = ::Provider.create!(attrs.merge(code: @provider_from_api.code))
        @updates.merge!(providers: true) if !@incremental_sync

        provider
      end
    end
  end
end
