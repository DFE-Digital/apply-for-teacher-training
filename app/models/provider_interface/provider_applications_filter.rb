module ProviderInterface
  class ProviderApplicationsFilter
    include FilterParamsHelper

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
      ([] << search_filter << recruitment_cycle_filter << status_filter << provider_filter << accredited_provider_filter << subject_filter << study_modes_filter).concat(provider_locations_filters).compact
    end

    def filtered?
      applied_filters.values.any?(&:present?)
    end

    def no_results_message
      filters_with_value = applied_filters.select { |_, value| value.present? }
      filtering_keys = filters_with_value.except(:remove).keys
      filter_count = filters_with_value.except(:candidate_name, :remove).keys.size

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
      compact_params(params.permit(:remove, :candidate_name, recruitment_cycle_year: [], provider: [], status: [], accredited_provider: [], provider_location: [], subject: [], study_mode: []).to_h)
    end

    def save_filter_state!
      @state_store.write(@applied_filters.to_json)
    end

    def last_saved_filter_state
      JSON.parse(@state_store.read || '{}').with_indifferent_access
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
      cycle_options = RecruitmentCycle.years_visible_to_providers
        .map do |year|
          year_str = year.to_s
          {
            value: year_str,
            label: RecruitmentCycle.cycle_string(year_str),
            checked: applied_filters[:recruitment_cycle_year]&.include?(year_str),
          }
        end

      {
        type: :checkboxes,
        heading: 'Recruitment cycle',
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
        heading: 'Training provider',
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
        heading: 'Accredited body',
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
        next unless provider.sites.for_recruitment_cycle_years([CycleTimetable.current_year, CycleTimetable.previous_year]).count > 1

        {
          type: :checkboxes,
          heading: "Locations for #{provider.name}",
          name: 'provider_location',
          options: provider.sites.for_recruitment_cycle_years([CycleTimetable.current_year, CycleTimetable.previous_year]).uniq { |site| [site.code, site.name] }.map do |site|
            {
              value: "#{site.name}_#{site.code}",
              label: site.name_and_code,
              checked: applied_filters[:provider_location]&.include?("#{site.name}_#{site.code}"),
            }
          end,
        }
      end
    end

    def subject_filter
      provider_ids = applied_filters[:provider].presence || ProviderOptionsService.new(provider_user).providers.pluck(:id)
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

    def study_modes_filter
      {
        type: :checkboxes,
        heading: 'Full time or part time',
        name: 'study_mode',
        options: CourseOption.study_modes.map do |study_mode|
          {
            value: study_mode.first,
            label: study_mode.first.humanize,
            checked: applied_filters[:study_mode]&.include?(study_mode.first.to_s),
          }
        end,
      }
    end
  end
end
