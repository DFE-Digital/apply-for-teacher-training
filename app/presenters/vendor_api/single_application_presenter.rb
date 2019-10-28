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
          updated_at: application_choice.updated_at,
          submitted_at: application_form.submitted_at,
          personal_statement: application_choice.personal_statement,
          candidate: {
            first_name: application_form.first_name,
            last_name: application_form.last_name,
            date_of_birth: application_form.date_of_birth,
            nationality: %w[NL],
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
            country: 'NL',
            email: application_form.candidate.email_address,
          },
          course: course_json,
          qualifications: {
            gcses: [
              {
                qualification_type: 'GCSE',
                subject: 'Maths',
                grade: 'A',
                award_year: '2001',
                equivalency_details: nil,
                institution_details: nil,
              },
              {
                qualification_type: 'GCSE',
                subject: 'English',
                grade: 'A',
                award_year: '2001',
                equivalency_details: nil,
                institution_details: nil,
              },
            ],
            degrees: [
              {
                qualification_type: 'BA',
                subject: 'Geography',
                grade: '2.1',
                award_year: '2007',
                equivalency_details: nil,
                institution_details: 'Imperial College London',
              },
            ],
            other_qualifications: [
              {
                qualification_type: '	A Level',
                subject: 'Chemistry',
                grade: 'B',
                award_year: '2004',
                equivalency_details: nil,
                institution_details: 'Harris Westminster Sixth Form	',
              },
            ],
          },
          references: [],
          work_experiences: [],
          offer: application_choice.offer,
          rejection: get_rejection,
          withdrawal: nil,
          hesa_itt_data: {
            sex: '',
            disability: '',
            ethnicity: '',
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
          date: Time.now,
        }
      end
    end

    def course_json
      {
        start_date: application_choice.course.start_date,
        provider_ucas_code: application_choice.provider.code,
        site_ucas_code: application_choice.site.code,
        course_ucas_code: application_choice.course.code,
      }
    end
  end
end
