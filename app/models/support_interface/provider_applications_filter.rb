module SupportInterface
  class ProviderApplicationsFilter
    include FilterParamsHelper

    attr_reader :applied_filters, :provider_page

    def initialize(params:, provider_page: false)
      @applied_filters = compact_params(params)
      @provider_page = provider_page
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

      if applied_filters[:q].present?
        application_forms = application_forms.where("CONCAT(application_forms.first_name, ' ', application_forms.last_name, ' ', candidates.email_address, ' ', application_forms.support_reference) ILIKE ?", "%#{applied_filters[:q]}%")
      end

      if applied_filters[:application_choice_id].present?
        application_forms = application_forms.joins(:application_choices).where(application_choices: { id: applied_filters[:application_choice_id].to_i })
      end

      if applied_filters[:phase].present?
        application_forms = application_forms.where(phase: applied_filters[:phase])
      end

      if applied_filters[:interviews].present?
        application_forms = application_forms.joins(application_choices: [:interviews]).group('id')
      end

      if applied_filters[:year].present?
        application_forms = application_forms.where(recruitment_cycle_year: applied_filters[:year])
      end

      if provider_page && applied_filters[:training_provider].present?
        application_forms = application_forms
                            .joins(application_choices: { course_option: :site })
                            .where(application_choices: { course_option: { sites: { provider_id: applied_filters[:training_provider] } } })
      end

      if provider_page && applied_filters[:accredited_provider].present?
        application_forms = application_forms
                            .joins(application_choices: { course_option: :course })
                            .where(application_choices: { course_option: { courses: { accredited_provider_id: applied_filters[:accredited_provider] } } })
      end

      if applied_filters[:status].present?
        application_forms = application_forms.joins(:application_choices).where(application_choices: { status: applied_filters[:status] })
      end

      if applied_filters[:provider_id]
        application_forms = application_forms
                              .joins(:application_choices)
                              .where('application_choices.provider_ids @> ?', "{#{applied_filters[:provider_id]}}")
      end

      application_forms
    end

    def filters
      @filters ||= if provider_page
                     [search_filter, search_by_application_choice_filter, year_filter, phase_filter, interviews_filter, training_provider_filter, accredited_provider_filter, status_filter]
                   else
                     [search_filter, search_by_application_choice_filter, year_filter, phase_filter, interviews_filter, status_filter]
                   end
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

    def training_provider_filter
      providers = Provider
                  .joins(:courses)
                  .where(id: @applied_filters['provider_id'], courses: { recruitment_cycle_year: RecruitmentCycle.current_year })
                  .or(
                    Course.where(accredited_provider_id: @applied_filters['provider_id'], recruitment_cycle_year: RecruitmentCycle.current_year),
                  )
                  .distinct

      provider_options = providers.map do |provider|
        {
          value: provider.id,
          label: provider.name,
          checked: applied_filters[:training_provider]&.include?(provider.id.to_s),
        }
      end

      {
        type: :checkboxes,
        heading: 'Training providers',
        name: 'training_provider',
        options: provider_options,
      }
    end

    def accredited_provider_filter
      courses = Course
                .joins(:provider)
                .includes([:accredited_provider])
                .current_cycle
                .where(provider: { id: @applied_filters['provider_id'] })
                .or(Course.current_cycle.where(accredited_provider_id: @applied_filters['provider_id']))
                .distinct

      accredited_providers = courses.map(&:accredited_provider).uniq.compact

      provider_options = accredited_providers.map do |provider|
        {
          value: provider.id,
          label: provider.name,
          checked: applied_filters[:accredited_provider]&.include?(provider.id.to_s),
        }
      end

      {
        type: :checkboxes,
        heading: 'Accredited providers',
        name: 'accredited_provider',
        options: provider_options,
      }
    end

    def status_filter
      {
        type: :checkboxes,
        heading: 'Status',
        name: 'status',
        options: [
          {
            value: 'unsubmitted',
            label: 'Not submitted yet',
            checked: applied_filters[:status]&.include?('unsubmitted'),
          },
          {
            value: 'awaiting_provider_decision',
            label: 'Awaiting provider decision',
            checked: applied_filters[:status]&.include?('awaiting_provider_decision'),
          },
          {
            value: 'interviewing',
            label: 'Interviewing',
            checked: applied_filters[:status]&.include?('interviewing'),
          },
          {
            value: 'offer',
            label: 'Offer made',
            checked: applied_filters[:status]&.include?('offer'),
          },
          {
            value: 'pending_conditions',
            label: 'Pending conditions',
            checked: applied_filters[:status]&.include?('pending_conditions'),
          },
          {
            value: 'conditions_met',
            label: 'Conditions met',
            checked: applied_filters[:status]&.include?('conditions_met'),
          },
          {
            value: 'rejected',
            label: 'Rejected',
            checked: applied_filters[:status]&.include?('rejected'),
          },
          {
            value: 'declined',
            label: 'Offer declined',
            checked: applied_filters[:status]&.include?('declined'),
          },
          {
            value: 'withdrawn',
            label: 'Withdrawn',
            checked: applied_filters[:status]&.include?('withdrawn'),
          },
          {
            value: 'conditions_not_met',
            label: 'Conditions not met',
            checked: applied_filters[:status]&.include?('conditions_not_met'),
          },
          {
            value: 'offer_withdrawn',
            label: 'Offer withdrawn',
            checked: applied_filters[:status]&.include?('offer_withdrawn'),
          },
          {
            value: 'offer_deferred',
            label: 'Offer deferred',
            checked: applied_filters[:status]&.include?('offer_deferred'),
          },
        ],
      }
    end
  end
end
