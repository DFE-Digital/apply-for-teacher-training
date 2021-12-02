module VendorAPI
  class ApplicationPresenter
    include Rails.application.routes.url_helpers

    include VendorAPI::Qualifications
    include VendorAPI::FieldTruncation
    include VendorAPI::WorkExperience

    UCAS_FEE_PAYER_CODES = {
      'SLC,SAAS,NIBd,EU,Chl,IoM' => '02',
      'Not Known' => '99',
    }.freeze
    API_APPLICATION_STATES = { offer_withdrawn: 'rejected',
                               interviewing: 'awaiting_provider_decision' }.freeze
    CACHE_EXPIRES_IN = 1.day

    attr_reader :application_choice

    def initialize(application_choice)
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
          candidate: {
            id: application_form.candidate.public_id,
            first_name: application_form.first_name,
            last_name: application_form.last_name,
            date_of_birth: application_form.date_of_birth,
            nationality: application_choice.nationalities,
            domicile: application_form.domicile,
            uk_residency_status: uk_residency_status,
            uk_residency_status_code: uk_residency_status_code,
            fee_payer: provisional_fee_payer_status,
            english_main_language: application_form.english_main_language,
            english_language_qualifications: application_form.english_language_qualification_details,
            other_languages: application_form.other_language_details,
            disability_disclosure: application_form.disability_disclosure,
          },
          contact_details: contact_details,
          course: course_info_for(application_choice.course_option),
          references: references,
          qualifications: qualifications,
          work_experience: {
            jobs: work_experience_jobs,
            volunteering: work_experience_volunteering,
            work_history_break_explanation: work_history_breaks,
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

    def hesa_itt_data
      return nil unless ApplicationStateChange::ACCEPTED_STATES.include?(application_choice.status.to_sym)

      equality_and_diversity_data = application_form&.equality_and_diversity

      if equality_and_diversity_data
        {
          sex: equality_and_diversity_data['hesa_sex'],
          disability: equality_and_diversity_data['hesa_disabilities'],
          ethnicity: equality_and_diversity_data['hesa_ethnicity'],
        }.merge(additional_hesa_itt_data(equality_and_diversity_data))
      end
    end

    def additional_hesa_itt_data(equality_and_diversity_data)
      {
        other_disability_details: other_disability_details(equality_and_diversity_data),
        other_ethnicity_details: other_ethnicity_details(equality_and_diversity_data),
      }
    end

    def uk_residency_status
      return 'UK Citizen' if application_choice.nationalities.include?('GB')

      return 'Irish Citizen' if application_choice.nationalities.include?('IE')

      return application_form.right_to_work_or_study_details if application_form.right_to_work_or_study_yes?

      'Candidate needs to apply for permission to work and study in the UK'
    end

    def uk_residency_status_code
      return 'A' if application_choice.nationalities.include?('GB')
      return 'B' if application_choice.nationalities.include?('IE')
      return 'D' if application_form.right_to_work_or_study_yes?

      'C'
    end

    def provisional_fee_payer_status
      return UCAS_FEE_PAYER_CODES['SLC,SAAS,NIBd,EU,Chl,IoM'] if provisionally_eligible_for_gov_funding?

      UCAS_FEE_PAYER_CODES['Not Known']
    end

    def provisionally_eligible_for_gov_funding?
      return true if (PROVISIONALLY_ELIGIBLE_FOR_GOV_FUNDING_COUNTRY_CODES & application_choice.nationalities).any?

      (EU_EEA_SWISS_COUNTRY_CODES & application_choice.nationalities).any? &&
        application_form.right_to_work_or_study_yes? &&
        application_form.uk_address?
    end

    def contact_details
      if application_form.international_address?
        address_line1 = application_form.address_line1 || application_form.international_address

        {
          phone_number: application_form.phone_number,
          address_line1: address_line1,
          address_line2: application_form.address_line2,
          address_line3: application_form.address_line3,
          address_line4: application_form.address_line4,
          country: application_form.country,
          email: application_form.candidate.email_address,
        }
      else
        {
          phone_number: application_form.phone_number,
          address_line1: application_form.address_line1,
          address_line2: application_form.address_line2,
          address_line3: application_form.address_line3,
          address_line4: application_form.address_line4,
          postcode: application_form.postcode,
          country: application_form.country,
          email: application_form.candidate.email_address,
        }
      end
    end

    def course_info_for(course_option)
      {
        recruitment_cycle_year: course_option.course.recruitment_cycle_year,
        provider_code: course_option.course.provider.code,
        site_code: course_option.site.code,
        course_code: course_option.course.code,
        study_mode: course_option.study_mode,
        start_date: course_option.course.start_date.strftime('%Y-%m'),
      }
    end

    def offer
      return nil if application_choice.offer.nil?

      {
        conditions: application_choice.offer.conditions_text,
        offer_made_at: application_choice.offered_at,
        offer_accepted_at: application_choice.accepted_at,
        offer_declined_at: application_choice.declined_at,
      }.merge(current_course)
    end

    def current_course
      { course: course_info_for(application_choice.current_course_option) }
    end

    def references
      references = application_form.application_references
      references.select { |reference| reference.selected && reference.feedback_provided? }.map do |reference|
        reference_to_hash(reference)
      end
    end

    def rejection
      @rejection ||= if application_choice.rejection_reason? || application_choice.structured_rejection_reasons.present?
                       {
                         reason: VendorAPI::RejectionReasonPresenter.new(application_choice).present,
                         date: application_choice.rejected_at.iso8601,
                       }
                     elsif application_choice.offer_withdrawal_reason?
                       {
                         reason: application_choice.offer_withdrawal_reason,
                         date: application_choice.offer_withdrawn_at.iso8601,
                       }
                     elsif application_choice.rejected_by_default?
                       {
                         reason: 'Not entered',
                         date: application_choice.rejected_at.iso8601,
                       }
                     end
      return if @rejection.blank?

      {
        reason: truncate_if_over_advertised_limit('Rejection.properties.reason', @rejection[:reason]),
        date: @rejection[:date],
      }
    end

    def withdrawal
      return unless application_choice.withdrawn?

      {
        reason: nil, # Candidates are not able to provide a withdrawal reason yet
        date: application_choice.withdrawn_at.iso8601,
      }
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
