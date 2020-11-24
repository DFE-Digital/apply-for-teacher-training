module FindSync
  class SyncProviderFromFind
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
        find_provider = fetch_provider_from_find_api

        @provider = create_or_update_provider(
          base_provider_attrs.merge(
            provider_attrs_from(find_provider),
          ),
        )

        if run_in_background
          FindSync::SyncCoursesFromFind.perform_async(provider.id, provider_recruitment_cycle_year)
        else
          FindSync::SyncCoursesFromFind.new.perform(provider.id, provider_recruitment_cycle_year)
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

    def provider_attrs_from(find_provider)
      {
        region_code: find_provider.region_code&.strip,
        postcode: find_provider.postcode,
        name: find_provider.provider_name,
      }
    end

    def existing_provider
      Provider.find_by(code: provider_code)
    end

    def create_or_update_provider(attrs)
      # Prefer this to find_or_create_by as it results in 3x fewer audits
      if existing_provider
        existing_provider.update!(attrs)
      else
        new_provider = Provider.new(attrs.merge(code: provider_code)).save!
      end

      existing_provider || new_provider
    end

    def fetch_provider_from_find_api
      # Request provider, all courses and sites.
      #
      # For the full response, see:
      # https://api2.publish-teacher-training-courses.service.gov.uk/api/v3/recruitment_cycles/2020/providers/1N1/?include=sites,courses.sites
      FindAPI::Provider
        .recruitment_cycle(provider_recruitment_cycle_year)
        .includes(:sites, courses: [:sites, :subjects, site_statuses: [:site]])
        .find(provider_code)
        .first
    end
  end
end
