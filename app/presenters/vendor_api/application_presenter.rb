module VendorAPI
  class ApplicationPresenter < Base
    VERSIONS = {
      '1.0' => [CandidateAPIData,
                QualificationAPIData,
                ContactDetailsAPIData,
                CourseAPIData,
                WorkExperienceAPIData,
                DecisionsAPIData,
                HesaIttDataAPIData],
    }.freeze

    API_APPLICATION_STATES = { offer_withdrawn: 'rejected',
                               interviewing: 'awaiting_provider_decision' }.freeze
    CACHE_EXPIRES_IN = 1.day

    attr_reader :application_choice

    def initialize(version, application_choice)
      super(version)
      @application_choice = ApplicationChoiceExportDecorator.new(application_choice)
    end

    def serialized_json
      Rails.cache.fetch(cache_key(application_choice), expires_in: CACHE_EXPIRES_IN) do
        schema.to_json
      end
    end

    def as_json
      Rails.cache.fetch(cache_key(application_choice, 'as_json'), expires_in: CACHE_EXPIRES_IN) do
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
          status: status,
          phase: application_form.phase,
          updated_at: application_choice.updated_at.iso8601,
          submitted_at: application_form.submitted_at.iso8601,
          personal_statement: personal_statement,
          interview_preferences: application_form.interview_preferences,
          reject_by_default_at: application_choice.reject_by_default_at&.iso8601,
          recruited_at: application_choice.recruited_at,
          hesa_itt_data: hesa_itt_data,
          candidate: candidate,
          contact_details: contact_details,
          course: course_info_for(application_choice.course_option),
          references: references,
          qualifications: qualifications,
          work_experience: {
            jobs: work_experience_jobs,
            volunteering: work_experience_volunteering,
            work_history_break_explanation: work_history_break_explanation,
          },
          offer: offer,
          rejection: rejection,
          withdrawal: withdrawal,
          further_information: application_form.further_information,
          safeguarding_issues_status: application_form.safeguarding_issues_status,
          safeguarding_issues_details_url: safeguarding_issues_details_url,
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
      "Why do you want to become a teacher?: #{application_form.becoming_a_teacher} \n " \
        "What is your subject knowledge?: #{application_form.subject_knowledge}"
    end

    def references
      references = application_form.application_references
      references.select { |reference| reference.selected && reference.feedback_provided? }.map do |reference|
        reference_to_hash(reference)
      end
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

    def cache_key(model, method = '')
      CacheKey.generate("#{model.cache_key_with_version}#{method}")
    end
  end
end
