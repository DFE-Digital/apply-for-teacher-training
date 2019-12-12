module VendorApi
  class SingleApplicationPresenter
    def initialize(application_choice)
      @application_choice = application_choice
      @application_form = application_choice.application_form
    end

    def as_json
      {
        id: application_choice.id.to_s,
        type: 'application',
        attributes: {
          status: application_choice.status,
          updated_at: application_choice.updated_at.iso8601,
          submitted_at: application_form.submitted_at.iso8601,
          personal_statement: personal_statement,
          interview_preferences: application_form.interview_preferences,
          candidate: {
            id: "C#{application_form.candidate.id}",
            first_name: application_form.first_name,
            last_name: application_form.last_name,
            date_of_birth: application_form.date_of_birth,
            nationality: nationalities,
            uk_residency_status: application_form.uk_residency_status,
            english_main_language: application_form.english_main_language,
            english_language_qualifications: application_form.english_language_details,
            other_languages: application_form.other_language_details,
            disability_disclosure: application_form.disability_disclosure,
          },
          contact_details: {
            phone_number: application_form.phone_number,
            address_line1: application_form.address_line1,
            address_line2: application_form.address_line2,
            address_line3: application_form.address_line3,
            address_line4: application_form.address_line4,
            postcode: application_form.postcode,
            country: application_form.country,
            email: application_form.candidate.email_address,
          },
          course: course,
          references: references,
          qualifications: qualifications,
          work_experience: {
            jobs: work_experience_jobs,
            volunteering: work_experience_volunteering,
          },
          offer: application_choice.offer,
          rejection: get_rejection,
          withdrawal: nil,
          hesa_itt_data: {
            sex: '2',
            disability: '00',
            ethnicity: '10',
          },
          further_information: application_form.further_information,
        },
      }
    end

  private

    attr_reader :application_choice, :application_form

    def get_rejection
      if application_choice.rejection_reason?
        {
          reason: application_choice.rejection_reason,
        }
      end
    end

    def nationalities
      [
        application_form.first_nationality,
        application_form.second_nationality,
      ].map { |n| NATIONALITIES_BY_NAME[n] }.compact
    end

    def course
      {
        start_date: application_choice.course.start_date,
        recruitment_cycle_year: application_choice.course.recruitment_cycle_year,
        provider_code: application_choice.provider.code,
        site_code: application_choice.site.code,
        course_code: application_choice.course.code,
        study_mode: 'full_time',
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
        start_date: experience.start_date.to_date,
        end_date: experience.end_date&.to_date,
        role: experience.role,
        organisation_name: experience.organisation,
        working_with_children: experience.working_with_children,
        commitment: experience.commitment,
        description: experience.details,
      }
    end

    def references
      application_form.references.map do |reference|
        reference_to_hash(reference)
      end
    end

    def reference_to_hash(reference)
      {
        name: reference.name,
        email: reference.email_address,
        relationship: reference.relationship,
        reference: reference.feedback,
      }
    end

    def qualifications
      {
        gcses: qualifications_of_level('gcse').map { |q| qualification_to_hash(q) },
        degrees: qualifications_of_level('degree').map { |q| qualification_to_hash(q) },
        other_qualifications: qualifications_of_level('other').map { |q| qualification_to_hash(q) },
      }
    end

    def qualifications_of_level(level)
      # NOTE: we do it this way so that it uses the already-included relation
      # rather than triggering separate queries, as it does if we use the scopes
      # .gcses .degrees etc
      application_form.application_qualifications.select do |q|
        q.level == level
      end
    end

    def qualification_to_hash(qualification)
      {
        qualification_type: qualification.qualification_type,
        subject: qualification.subject,
        grade: "#{qualification.grade}#{' (Predicted)' if qualification.predicted_grade}",
        award_year: qualification.award_year,
        institution_details: institution_details(qualification),
        awarding_body: qualification.awarding_body,
        equivalency_details: qualification.equivalency_details,
      }
    end

    def institution_details(qualification)
      if qualification.institution_name
        [qualification.institution_name, qualification.institution_country].compact.join(', ')
      end
    end

    def personal_statement
      "Why do you want to become a teacher?: #{application_form.becoming_a_teacher} \n What is your subject knowledge?: #{application_form.subject_knowledge}"
    end
  end
end
