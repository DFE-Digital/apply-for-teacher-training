module SupportInterface
  class UCASMatchesFilter
    attr_reader :applied_filters

    def initialize(params:)
      @applied_filters = params
    end

    def filter_records(ucas_matches)
      if applied_filters[:years]
        ucas_matches = ucas_matches.where(recruitment_cycle_year: applied_filters[:years])
      end

      if applied_filters[:action_needed]&.include?('yes')
        action_needed_ids = ucas_matches.select(&:action_needed?).map(&:id)
        ucas_matches = ucas_matches.where(id: action_needed_ids)
      end

      if applied_filters[:action_taken]
        ucas_matches = ucas_matches.where(action_taken: applied_filters[:action_taken])
      end

      ucas_matches
    end

    def filters
      @filters ||= [year_filter] + [action_needed_filter] + [action_taken_filter]
    end

  private

    def year_filter
      cycle_options = RecruitmentCycle::CYCLES.map do |year, label|
        {
          value: year,
          label: label,
          checked: applied_filters[:years]&.include?(year),
        }
      end

      {
        type: :checkboxes,
        heading: 'Recruitment cycle year',
        name: 'years',
        options: cycle_options,
      }
    end

    def action_needed_filter
      {
        type: :checkboxes,
        heading: 'Action needed',
        name: 'action_needed',
        options: [{
          value: 'yes',
          label: 'Yes',
          checked: applied_filters[:action_needed]&.include?('yes'),
        }],
      }
    end

    def action_taken_filter
      {
        type: :checkboxes,
        heading: 'Last action taken',
        name: 'action_taken',
        options: action_taken_options,
      }
    end

    def action_taken_options
      UCASMatch.distinct(:action_taken).pluck(:action_taken).compact.map do |action|
        {
          value: action,
          label: action.humanize,
          checked: applied_filters[:action_taken]&.include?(action),
        }
      end
    end
  end
end
