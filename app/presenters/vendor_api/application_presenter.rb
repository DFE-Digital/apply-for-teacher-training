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
                               interviewing: 'awaiting_provider_decision' }.freeze
    CACHE_EXPIRES_IN = 1.day

    attr_reader :application_choice, :include_incomplete_references

    def initialize(version, application_choice, include_incomplete_references: false)
      super(version)
      @application_choice = ApplicationChoiceExportDecorator.new(application_choice)
      @include_incomplete_references = include_incomplete_references
    end

    def serialized_json
      Rails.cache.fetch(cache_key(application_choice, active_version, cache_key_suffixes), expires_in: CACHE_EXPIRES_IN) do
        schema.to_json
      end
    end

    def as_json
      key = cache_key(application_choice, active_version, cache_key_suffixes.merge(method: :as_json))
      Rails.cache.fetch(key, expires_in: CACHE_EXPIRES_IN) do
        schema
      end
    end

  private

    def cache_key_suffixes
      { incomplete_references: include_incomplete_references }
    end

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
          personal_statement:,
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
        },
      }
    end

    def application_form
      @application_form ||= application_choice.application_form
    end

    def status
      API_APPLICATION_STATES[application_choice.status.to_sym].presence || application_choice.status
    end

    def personal_statement
      "Why do you want to be a teacher?: #{application_form.becoming_a_teacher} \n " \
        "What is your subject knowledge?: #{application_form.subject_knowledge}"
    end

    def references
      references = application_form.application_references

      return [] unless application_is_in_an_accepted_state?

      references.feedback_provided.map { |reference| reference_to_hash(reference) }
    end

    def safeguarding_issues_details_url
      application_form.has_safeguarding_issues_to_declare? ? provider_interface_application_choice_url(application_choice, anchor: 'criminal-convictions-and-professional-misconduct') : nil
    end

    def reference_to_hash(reference)
      {
        id: reference.id,
        name: reference.name,
        email: reference.email_address,
        relationship: reference.relationship,
        reference: reference.feedback,
        referee_type: reference.referee_type,
        safeguarding_concerns: reference.has_safeguarding_concerns_to_declare?,
      }
    end

    def domicile
      return 'ZZ' if application_form.domicile.size > 2

      application_form.domicile
    end

    def country
      application_form.country[0..1] if application_form.country.present?
    end

    def application_is_in_an_accepted_state?
      ApplicationStateChange::ACCEPTED_STATES.include?(application_choice.status.to_sym)
    end
  end
end
