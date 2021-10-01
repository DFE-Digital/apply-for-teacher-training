module SupportInterface
  class CandidateApplicationsFilter
    include FilterParamsHelper
    include ApplicationFilterHelper

    attr_reader :applied_filters

    def initialize(params:)
      @applied_filters = compact_params(params)
    end

    def filter_records(application_forms)
      application_forms = load_applications(application_forms)
      application_forms = apply_name_email_or_reference_filter(application_forms) if applied_filters[:q].present?
      application_forms = apply_application_choice_id_filter(application_forms) if applied_filters[:application_choice_id].present?
      application_forms = apply_phase_filter(application_forms) if applied_filters[:phase].present?
      application_forms = apply_interviews_filter(application_forms) if applied_filters[:interviews].present?
      application_forms = apply_year_filter(application_forms) if applied_filters[:year].present?
      application_forms = apply_status_filter(application_forms) if applied_filters[:status].present?
      application_forms = apply_provider_id_filter(application_forms) if applied_filters[:provider_id]
      application_forms
    end

    def filters
      @filters ||= [search_filter, search_by_application_choice_filter, year_filter, phase_filter, interviews_filter, status_filter]
    end
  end
end
