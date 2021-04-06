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
        heading: 'Cycle',
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
      return [] if applied_filters[:provider].nil?

      providers = ProviderOptionsService.new(provider_user).providers_with_sites(provider_ids: applied_filters[:provider])

      providers.map do |p|
        next unless p.sites.count > 1

        {
          type: :checkboxes,
          heading: "Locations for #{p.name}",
          name: 'provider_location',
          options: p.sites.map do |s|
            {
              value: s.id,
              label: s.name,
              checked: applied_filters[:provider_location]&.include?(s.id.to_s),
            }
          end,
        }
      end
    end

    def subject_filter
      {
        type: :checkbox_filter,
        heading: 'Search for subject',
        name: 'subject',
        options: [
          OpenStruct.new(id: 1, name: 'Art & Design'),
          OpenStruct.new(id: 2, name: 'Biology'),
          OpenStruct.new(id: 3, name: 'Business studies'),
          OpenStruct.new(id: 4, name: 'Chemistry'),
          OpenStruct.new(id: 5, name: 'Citizenship'),
          OpenStruct.new(id: 6, name: 'Classics'),
          OpenStruct.new(id: 7, name: 'Communications and media studies'),
          OpenStruct.new(id: 8, name: 'Computer science'),
          OpenStruct.new(id: 9, name: 'Dance'),
          OpenStruct.new(id: 10, name: 'Design and technology'),
          OpenStruct.new(id: 11, name: 'Drama'),
          OpenStruct.new(id: 12, name: 'Economics'),
          OpenStruct.new(id: 13, name: 'English'),
          OpenStruct.new(id: 14, name: 'English as a second or other language'),
          OpenStruct.new(id: 15, name: 'French'),
          OpenStruct.new(id: 16, name: 'Geography'),
          OpenStruct.new(id: 17, name: 'German'),
          OpenStruct.new(id: 18, name: 'Health and social care'),
          OpenStruct.new(id: 19, name: 'History'),
          OpenStruct.new(id: 20, name: 'Italian'),
          OpenStruct.new(id: 21, name: 'Japanese'),
          OpenStruct.new(id: 22, name: 'Mandarin'),
          OpenStruct.new(id: 23, name: 'Mathematics'),
          OpenStruct.new(id: 24, name: 'Modern languages (other)'),
          OpenStruct.new(id: 25, name: 'Music'),
          OpenStruct.new(id: 26, name: 'Physical education'),
          OpenStruct.new(id: 27, name: 'Physics'),
          OpenStruct.new(id: 28, name: 'Primary'),
          OpenStruct.new(id: 29, name: 'Primary with English'),
          OpenStruct.new(id: 30, name: 'Primary with geography and history'),
          OpenStruct.new(id: 31, name: 'Primary with mathematics'),
          OpenStruct.new(id: 32, name: 'Primary with modern languages'),
          OpenStruct.new(id: 33, name: 'Primary with physical education'),
          OpenStruct.new(id: 34, name: 'Primary with science'),
          OpenStruct.new(id: 35, name: 'Psychology'),
          OpenStruct.new(id: 36, name: 'Religious education'),
          OpenStruct.new(id: 37, name: 'Russian'),
          OpenStruct.new(id: 38, name: 'Science'),
          OpenStruct.new(id: 38, name: 'Social sciences'),
          OpenStruct.new(id: 38, name: 'Spanish'),
        ].map do |s|
          {
            value: s.id,
            label: s.name,
            checked: applied_filters[:subject]&.include?(s.id.to_s),
          }
        end,
      }
    end
  end
end
