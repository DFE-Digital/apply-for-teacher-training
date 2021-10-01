module SupportInterface
  class ProviderApplicationsFilter
    include FilterParamsHelper
    include ApplicationFilterHelper

    attr_reader :applied_filters

    def initialize(params:)
      @applied_filters = compact_params(params)
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

      if applied_filters[:training_provider].present?
        application_forms = application_forms
                            .joins(application_choices: { course_option: :site })
                            .where(application_choices: { course_option: { sites: { provider_id: applied_filters[:training_provider] } } })
      end

      if applied_filters[:accredited_provider].present?
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
      @filters ||= [search_filter, search_by_application_choice_filter, year_filter, phase_filter, interviews_filter, training_provider_filter, accredited_provider_filter, status_filter]
    end
  end
end
