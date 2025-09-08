module VendorAPI
  class ApplicationPresenter < Base
    include CandidateAPIData
    include QualificationAPIData
    include ContactDetailsAPIData
    include CourseAPIData
    include WorkExperienceAPIData
    include DecisionsAPIData
    include HesaIttDataAPIData

    API_APPLICATION_STATES = { offer_withdrawn: 'rejected',
                               inactive: 'awaiting_provider_decision',
                               interviewing: 'awaiting_provider_decision' }.freeze
    CACHE_EXPIRES_IN = 1.day

    attr_reader :application_choice

    def initialize(version, application_choice)
      super(version)
      @application_choice = ApplicationChoiceExportDecorator.new(application_choice)
    end

    def serialized_json
      Rails.cache.fetch(cache_key(application_choice, active_version), expires_in: CACHE_EXPIRES_IN) do
        schema.to_json
      end
    end

    def as_json
      key = cache_key(application_choice, active_version, method: :as_json)
      Rails.cache.fetch(key, expires_in: CACHE_EXPIRES_IN) do
        schema
      end
    end

  private

    def schema
      {
        id: application_choice.id.to_s,
        type: 'application',
        attributes: {
          application_url: provider_interface_application_choice_url(application_choice),
          support_reference: application_form.support_reference,
          status:,
          phase: application_form.phase,
          updated_at: application_choice.updated_at.iso8601,
          submitted_at: application_form.submitted_at.iso8601,
          personal_statement: application_choice.personal_statement,
          interview_preferences: application_form.interview_preferences,
          reject_by_default_at: application_choice.reject_by_default_at&.iso8601,
          recruited_at: application_choice.recruited_at,
          hesa_itt_data:,
          candidate:,
          contact_details:,
          course: course_info_for(application_choice.course_option),
          references:,
          qualifications:,
          work_experience: {
            jobs: work_experience_jobs,
            volunteering: work_experience_volunteering,
            work_history_break_explanation:,
          },
          offer:,
          rejection:,
          withdrawal:,
          further_information: application_form.further_information,
          safeguarding_issues_status: application_form.safeguarding_issues_status,
          safeguarding_issues_details_url:,
          anonymised:,
        },
      }
    end

    def application_form
      @application_form ||= application_choice.application_form
    end

    def status
      API_APPLICATION_STATES[application_choice.status.to_sym].presence || application_choice.status
    end

    def references
      return [] unless show_references?

      references = if version_1_3_or_above?
                     application_form.application_references.creation_order.reject { |reference| reference.feedback_status == 'not_requested_yet' }
                   else
                     application_form.application_references.creation_order.feedback_provided
                   end

      references.map { |reference| reference_to_hash(reference) }
    end

    def show_references?
      (version_1_3_or_above? && !application_unsuccessful?) ||
        application_accepted?
    end

    def version_1_3_or_above?
      Gem::Version.new(active_version) >= Gem::Version.new('1.3')
    end

    def safeguarding_issues_details_url
      application_form.has_safeguarding_issues_to_declare? ? provider_interface_application_choice_url(application_choice, anchor: 'criminal-convictions-and-professional-misconduct') : nil
    end

    def anonymised
      IsApplicationAnonymised.new(application_form: application_form).call
    end

    def reference_to_hash(reference)
      VendorAPI::ReferencePresenter.new(active_version, reference, application_accepted: application_accepted?).schema
    end

    def domicile
      return 'ZZ' if (application_form.country.presence&.size || 0) > 2

      application_form.domicile
    end

    def country
      application_form.country[0..1] if application_form.country.present?
    end

    def application_accepted?
      ApplicationStateChange::ACCEPTED_STATES.include?(application_choice.status.to_sym)
    end

    def application_unsuccessful?
      ApplicationStateChange::UNSUCCESSFUL_STATES.include?(application_choice.status.to_sym)
    end
  end
end
