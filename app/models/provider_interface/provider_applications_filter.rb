module ProviderInterface
  class ProviderApplicationsFilter
    attr_accessor :available_filters, :filter_selections, :provider_user
    attr_reader :applied_filters

    STATE_STORE_KEY = :provider_interface_applications_page_state

    def initialize(params:, provider_user:, state_store:)
      @provider_user = provider_user
      @applied_filters = parse_params(params)
      @state_store = state_store

      if @applied_filters.empty?
        @applied_filters = last_saved_filter_state
      else
        save_filter_state!
      end
    end

    def filters
      ([] << search_filter << recruitment_cycle_filter << status_filter << provider_filter << accredited_provider_filter << subject_filter).concat(provider_locations_filters).compact
    end

    def filtered?
      applied_filters.values.any?
    end

    def no_results_message
      filtering_keys = applied_filters.except(:remove).keys
      filter_count = applied_filters.except(:candidate_name, :remove).keys.size

      if filtering_keys == %w[candidate_name]
        "There are no results for '#{applied_filters['candidate_name']}'."
      elsif filtering_keys.include?('candidate_name')
        "There are no results for '#{applied_filters['candidate_name']}' and the selected #{'filter'.pluralize(filter_count)}."
      else
        "There are no results for the selected #{'filter'.pluralize(filter_count)}."
      end
    end

  private

    def parse_params(params)
      params.permit(:remove, :candidate_name, recruitment_cycle_year: [], provider: [], status: [], accredited_provider: [], provider_location: [], subject: []).to_h
    end

    def save_filter_state!
      @state_store[STATE_STORE_KEY] = @applied_filters.to_json
    end

    def last_saved_filter_state
      JSON.parse(@state_store[STATE_STORE_KEY] || '{}').with_indifferent_access
    end

    def search_filter
      {
        type: :search,
        heading: 'Candidate name or reference',
        value: applied_filters[:candidate_name],
        name: 'candidate_name',
        primary: true,
      }
    end

    def recruitment_cycle_filter
      cycle_options = RecruitmentCycle::CYCLES.map do |year, label|
        {
          value: year,
          label: label,
          checked: applied_filters[:recruitment_cycle_year]&.include?(year),
        }
      end

      {
        type: :checkboxes,
        heading: 'Year received',
        name: 'recruitment_cycle_year',
        options: cycle_options,
      }
    end

    def status_filter
      status_options = ApplicationStateChange.states_visible_to_provider.map do |state_name|
        {
          value: state_name.to_s,
          label: I18n.t!("provider_application_states.#{state_name}"),
          checked: applied_filters[:status]&.include?(state_name.to_s),
        }
      end

      {
        type: :checkboxes,
        heading: 'Status',
        name: 'status',
        options: status_options,
      }
    end

    def provider_filter
      providers = ProviderOptionsService.new(provider_user).providers

      return nil if providers.size < 2

      provider_options = providers.map do |provider|
        {
          value: provider.id,
          label: provider.name,
          checked: applied_filters[:provider]&.include?(provider.id.to_s),
        }
      end

      {
        type: :checkboxes,
        heading: 'Courses run by',
        name: 'provider',
        options: provider_options,
      }
    end

    def accredited_provider_filter
      accredited_providers = ProviderOptionsService.new(provider_user).accredited_providers

      return nil if accredited_providers.empty?

      accredited_providers_options = accredited_providers.map do |accredited_provider|
        {
          value: accredited_provider.id,
          label: accredited_provider.name,
          checked: applied_filters[:accredited_provider]&.include?(accredited_provider.id.to_s),
        }
      end

      {
        type: :checkboxes,
        heading: 'Courses ratified by',
        name: 'accredited_provider',
        options: accredited_providers_options,
      }
    end

    def provider_locations_filters
      user_provider_ids = ProviderOptionsService.new(provider_user).providers.pluck(:id)
      return [] if applied_filters[:provider].nil? && user_provider_ids.length > 1

      selected_provider_ids = applied_filters[:provider].presence || user_provider_ids
      providers = ProviderOptionsService.new(provider_user).providers_with_sites(provider_ids: selected_provider_ids)

      providers.map do |provider|
        next unless provider.sites.count > 1

        {
          type: :checkboxes,
          heading: "Locations for #{provider.name}",
          name: 'provider_location',
          options: provider.sites.map do |site|
            {
              value: site.id,
              label: site.name,
              checked: applied_filters[:provider_location]&.include?(site.id.to_s),
            }
          end,
        }
      end
    end

    def subject_filter
      provider_ids = applied_filters[:provider] || ProviderOptionsService.new(provider_user).providers.pluck(:id)
      provider_courses = Course.where(provider_id: provider_ids)

      {
        type: :checkbox_filter,
        heading: 'Subject',
        name: 'subject',
        options: Subject.joins(:courses).merge(provider_courses).order(:name).distinct
        .map do |subject|
          {
            value: subject.id,
            label: subject.name,
            checked: applied_filters[:subject]&.include?(subject.id.to_s),
          }
        end,
      }
    end
  end
end
