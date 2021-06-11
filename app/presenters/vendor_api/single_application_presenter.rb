module VendorAPI
  class SingleApplicationPresenter
    include Rails.application.routes.url_helpers

    UCAS_FEE_PAYER_CODES = {
      'SLC,SAAS,NIBd,EU,Chl,IoM' => '02',
      'Not Known' => '99',
    }.freeze

    def initialize(application_choice)
      @application_choice = ApplicationChoiceExportDecorator.new(application_choice)
      @application_form = application_choice.application_form
    end

    def as_json
      hash = {
        id: application_choice.id.to_s,
        type: 'application',
        attributes: {
          support_reference: application_form.support_reference,
          status: status,
          phase: application_form.phase,
          updated_at: application_choice.updated_at.iso8601,
          submitted_at: application_form.submitted_at.iso8601,
          personal_statement: personal_statement,
          interview_preferences: application_form.interview_preferences,
          reject_by_default_at: application_choice.reject_by_default_at&.iso8601,
          recruited_at: application_choice.recruited_at,
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
          rejection: get_rejection,
          withdrawal: withdrawal,
          further_information: application_form.further_information,
          safeguarding_issues_status: application_form.safeguarding_issues_status,
          safeguarding_issues_details_url: safeguarding_issues_details_url,
        },
      }

      if ApplicationStateChange::ACCEPTED_STATES.include? application_choice.status.to_sym
        hash[:attributes][:hesa_itt_data] = hesa_itt_data
      else
        hash[:attributes][:hesa_itt_data] = nil
      end

      hash
    end

  private

    attr_reader :application_choice, :application_form

    # V2: handles backwards compatibility (`offer_withdrawn` state is displayed as `rejected`) and
    #     converting statuses that cannot be handles by Vendor.
    def status
      if application_choice.offer_withdrawn?
        'rejected'
      elsif application_choice.interviewing?
        'awaiting_provider_decision'
      else
        application_choice.status
      end
    end

    def get_rejection
      if application_choice.rejection_reason? || application_choice.structured_rejection_reasons.present?
        {
          reason: RejectionReasonPresenter.new(application_choice).present,
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
    end

    def withdrawal
      return unless application_choice.withdrawn?

      {
        reason: nil, # Candidates are not able to provide a withdrawal reason yet
        date: application_choice.withdrawn_at.iso8601,
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

    def work_experience_jobs
      application_form.application_work_experiences.map do |experience|
        experience_to_hash(experience)
      end
    end

    def work_experience_volunteering
      application_form.application_volunteering_experiences.map do |experience|
        experience_to_hash(experience)
      end
    end

    def experience_to_hash(experience)
      {
        id: experience.id,
        start_date: experience.start_date.to_date,
        end_date: experience.end_date&.to_date,
        role: experience.role,
        organisation_name: experience.organisation,
        working_with_children: experience.working_with_children,
        commitment: experience.commitment,
        description: experience_description(experience),
      }
    end

    def experience_description(experience)
      return experience.details if experience.working_pattern.blank?

      "Working pattern: #{experience.working_pattern}\n\nDescription: #{experience.details}"
    end

    def references
      application_form.application_references.selected.map do |reference|
        reference_to_hash(reference)
      end
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

    def qualifications
      {
        gcses: format_gcses,
        degrees: qualifications_of_level('degree').map { |q| qualification_to_hash(q) },
        other_qualifications: qualifications_of_level('other').map { |q| qualification_to_hash(q) },
        missing_gcses_explanation: application_choice.missing_gcses_explanation(separator_string: "\n\n"),
      }
    end

    def format_gcses
      gcses = qualifications_of_level('gcse').reject(&:missing_qualification?)

      # This is to split structured GCSEs in to separate GCSE qualifications for the API
      # Science triple award grades are already properly formatted and so are left out here
      to_structure, already_structured = gcses.partition do |gcse|
        gcse[:subject] != 'science triple award' && gcse[:constituent_grades].present?
      end

      separated_gcse_hashes = to_structure.flat_map { |q| structured_gcse_to_hashes(q) }
      other_gcses_hashes = already_structured.map { |q| qualification_to_hash(q) }

      other_gcses_hashes + separated_gcse_hashes
    end

    def qualifications_of_level(level)
      # NOTE: we do it this way so that it uses the already-included relation
      # rather than triggering separate queries, as it does if we use the scopes
      # .gcses .degrees etc
      application_form.application_qualifications.select do |q|
        q.level == level
      end
    end

    def structured_gcse_to_hashes(gcse)
      constituent_grades = gcse[:constituent_grades]
      constituent_grades.reduce([]) do |array, (subject, hash)|
        array << qualification_to_hash(gcse)
                     .merge(
                       subject: subject.humanize,
                       subject_code: subject_code_for_gcse(subject),
                       grade: hash['grade'],
                       id: hash['public_id'],
                     )
      end
    end

    def qualification_to_hash(qualification)
      {
        id: qualification.public_id,
        qualification_type: qualification.qualification_type,
        non_uk_qualification_type: qualification.non_uk_qualification_type,
        subject: qualification.subject,
        subject_code: subject_code(qualification),
        grade: grade_details(qualification),
        start_year: qualification.start_year,
        award_year: qualification.award_year,
        institution_details: institution_details(qualification),
        awarding_body: nil, # included for backwards compatibility. This column is always blank
        equivalency_details: qualification.composite_equivalency_details,
      }.merge HesaQualificationFieldsPresenter.new(qualification).to_hash
    end

    def subject_code(qualification)
      if qualification.gcse?
        subject_code_for_gcse(qualification.subject)
      elsif qualification.other?
        subject_code_for_other_qualification(qualification)
      end
    end

    def subject_code_for_gcse(subject)
      GCSE_SUBJECTS_TO_CODES[subject]
    end

    def subject_code_for_other_qualification(qualification)
      if qualification.qualification_type == 'GCSE'
        subject_code_for_gcse(qualification.subject)
      elsif ['A level', 'AS level'].include? qualification.qualification_type
        A_AND_AS_LEVEL_SUBJECTS_TO_CODES[qualification.subject]
      end
    end

    def grade_details(qualification)
      grade = nil

      if qualification.grade
        if qualification.predicted_grade
          grade = "#{qualification.grade} (Predicted)"
        else
          grade = qualification.grade
        end
      end

      constituent_grades = qualification.constituent_grades

      # For triple award science we need to serialize 'grades' to the 'grade' field
      # in the specified order
      if qualification.subject == 'science triple award' && constituent_grades
        grade = "#{constituent_grades['biology']['grade']}#{constituent_grades['chemistry']['grade']}#{constituent_grades['physics']['grade']}"
      end

      grade || 'Not entered'
    end

    def institution_details(qualification)
      if qualification.institution_name
        [qualification.institution_name, qualification.institution_country].compact.join(', ')
      end
    end

    def personal_statement
      "Why do you want to become a teacher?: #{application_form.becoming_a_teacher} \n What is your subject knowledge?: #{application_form.subject_knowledge}"
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

    def current_course
      { course: course_info_for(application_choice.current_course_option) }
    end

    def offer
      return nil if application_choice.offer.nil?

      {
        conditions: application_choice.offer.reload.conditions_text,
        offer_made_at: application_choice.offered_at,
        offer_accepted_at: application_choice.accepted_at,
        offer_declined_at: application_choice.declined_at,
      }.merge(current_course)
    end

    def hesa_itt_data
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

    def other_disability_details(equality_and_diversity_data)
      return unless equality_and_diversity_data['hesa_disabilities']&.include?('96')

      standard_disabilities = DisabilityHelper::STANDARD_DISABILITIES.map(&:last)
      (equality_and_diversity_data['disabilities'] - standard_disabilities).first.presence
    end

    def other_ethnicity_details(equality_and_diversity_data)
      known_ethnic_backgrounds = OTHER_ETHNIC_BACKGROUNDS.values + ETHNIC_BACKGROUNDS.values.flatten + ['Prefer not to say']
      return if known_ethnic_backgrounds.include?(equality_and_diversity_data['ethnic_background'])

      equality_and_diversity_data['ethnic_background']
    end

    def work_history_breaks
      # With the new feature of adding individual work history breaks, `application_form.work_history_breaks`
      # is a legacy column. So we'll need to check if an application form has this value first.
      if application_form.work_history_breaks
        application_form.work_history_breaks
      elsif application_form.application_work_history_breaks.any?
        breaks = application_form.application_work_history_breaks.map do |work_break|
          start_date = work_break.start_date.to_s(:month_and_year)
          end_date = work_break.end_date.to_s(:month_and_year)

          "#{start_date} to #{end_date}: #{work_break.reason}"
        end

        breaks.join("\n\n")
      else
        ''
      end
    end

    def safeguarding_issues_details_url
      application_form.has_safeguarding_issues_to_declare? ? provider_interface_application_choice_url(application_choice, anchor: 'criminal-convictions-and-professional-misconduct') : nil
    end
  end
end
