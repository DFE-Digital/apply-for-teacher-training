module SupportInterface
  class ApplicationsFilter
    attr_reader :applied_filters

    def initialize(params:)
      @applied_filters = params
    end

    def filter_records(application_forms)
      application_forms = application_forms
        .joins(
          :candidate,
        )
        .preload(
          :candidate,
          application_choices: { course_option: { course: :provider } },
        )
        .order(updated_at: :desc)
        .page(applied_filters[:page] || 1).per(30)

      if applied_filters[:q]
        application_forms = application_forms.where("CONCAT(application_forms.first_name, ' ', application_forms.last_name, ' ', candidates.email_address, ' ', application_forms.support_reference) ILIKE ?", "%#{applied_filters[:q]}%")
      end

      if applied_filters[:application_choice_id].present?
        application_forms = application_forms.joins(:application_choices).where('application_choices.id = ?', applied_filters[:application_choice_id].to_i)
      end

      if applied_filters[:phase]
        application_forms = application_forms.where('phase IN (?)', applied_filters[:phase])
      end

      if applied_filters[:interviews]
        application_forms = application_forms.joins(application_choices: [:interviews]).group('id')
      end

      if applied_filters[:year]
        application_forms = application_forms.where('recruitment_cycle_year IN (?)', applied_filters[:year])
      end

      application_forms
    end

    def filters
      @filters ||= [search_filter, search_by_application_choice_filter, year_filter, phase_filter, interviews_filter]
    end

  private

    def year_filter
      cycle_options = RecruitmentCycle::CYCLES.map do |year, label|
        {
          value: year,
          label: label,
          checked: applied_filters[:year]&.include?(year),
        }
      end

      {
        type: :checkboxes,
        heading: 'Recruitment cycle year',
        name: 'year',
        options: cycle_options,
      }
    end

    def search_filter
      {
        type: :search,
        heading: 'Name, email or reference',
        value: applied_filters[:q],
        name: 'q',
      }
    end

    def search_by_application_choice_filter
      {
        type: :search,
        css_classes: 'govuk-input--width-5',
        heading: 'Provider application ID',
        value: applied_filters[:application_choice_id],
        name: 'application_choice_id',
      }
    end

    def phase_filter
      {
        type: :checkboxes,
        heading: 'Phase',
        name: 'phase',
        options: [
          {
            value: 'apply_1',
            label: 'Apply 1',
            checked: applied_filters[:phase]&.include?('apply_1'),
          },
          {
            value: 'apply_2',
            label: 'Apply 2',
            checked: applied_filters[:phase]&.include?('apply_2'),
          },
        ],
      }
    end

    def interviews_filter
      {
        type: :checkboxes,
        heading: 'Interviews',
        name: 'interviews',
        options: [
          {
            value: 'has_interviews',
            label: 'Has interviews',
            checked: applied_filters[:interviews]&.include?('has_interviews'),
          },
        ],
      }
    end
  end
end
