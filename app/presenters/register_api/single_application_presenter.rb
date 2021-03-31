module RegisterAPI
  class SingleApplicationPresenter
    UCAS_FEE_PAYER_CODES = {
      'SLC,SAAS,NIBd,EU,Chl,IoM' => '02',
      'Not Known' => '99',
    }.freeze

    def initialize(application_choice)
      @application_choice = ApplicationChoiceExportDecorator.new(application_choice)
      @application_form = application_choice.application_form
    end

    def as_json
      {
        id: application_choice.id.to_s,
        type: 'application',
        attributes: {
          support_reference: application_form.support_reference,
          status: status, # keep to show offer withdrawn and deferred
          updated_at: application_choice.updated_at.iso8601,
          submitted_at: application_form.submitted_at.iso8601,
          recruited_at: application_choice.recruited_at.iso8601,
          candidate: {
            id: "C#{application_form.candidate.id}",
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
            gender: equality_and_diversity_data['sex'],
            disabilities: equality_and_diversity_data['disabilities'].presence || [],
            ethnic_group: equality_and_diversity_data['ethnic_group'],
            ethnic_background: equality_and_diversity_data['ethnic_background'],
          },
          contact_details: contact_details,
          course: course_info_for(application_choice.offered_option),
          qualifications: qualifications,
          hesa_itt_data: hesa_itt_data.presence || {},
        },
      }
    end

  private

    attr_reader :application_choice, :application_form

    def status
      application_choice.status
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
        application_form.uk?
    end

    def course_info_for(course_option)
      {
        recruitment_cycle_year: course_option.course.recruitment_cycle_year,
        course_code: course_option.course.code,
        training_provider_code: course_option.course.provider.code,
        site_code: course_option.site.code,
        study_mode: course_option.study_mode,
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
                     .merge(subject: subject.humanize, grade: hash['grade'], id: hash['public_id'])
      end
    end

    def qualification_to_hash(qualification)
      {
        id: qualification.public_id,
        qualification_type: qualification.qualification_type,
        non_uk_qualification_type: qualification.non_uk_qualification_type,
        subject: qualification.subject,
        grade: grade_details(qualification),
        start_year: qualification.start_year,
        award_year: qualification.award_year,
        institution_details: institution_details(qualification),
        equivalency_details: qualification.composite_equivalency_details,
        comparable_uk_degree: qualification.comparable_uk_degree,
      }.merge HesaQualificationFieldsPresenter.new(qualification).to_hash
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

      grade
    end

    def institution_details(qualification)
      if qualification.institution_name
        [qualification.institution_name, qualification.institution_country].compact.join(', ')
      end
    end

    def contact_details
      if application_form.international?
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

    def hesa_itt_data
      if equality_and_diversity_data.present?
        {
          sex: equality_and_diversity_data['hesa_sex'],
          disability: equality_and_diversity_data['hesa_disabilities'],
          ethnicity: equality_and_diversity_data['hesa_ethnicity'],
        }
      end
    end

    def equality_and_diversity_data
      application_form.equality_and_diversity || {}
    end
  end
end
