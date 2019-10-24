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
          submitted_at: Time.now,
          personal_statement: application_choice.personal_statement,
          candidate: {
            first_name: application_form.first_name,
            last_name: application_form.last_name,
            date_of_birth: application_form.date_of_birth,
            nationality: %w[NL],
            uk_residency_status: application_form.uk_residency_status,
            english_main_language: true,
            english_language_qualifications: '',
            other_languages: '',
            disability_disclosure: '',
          },
          contact_details: {
            phone_number: '',
            address_line1: '',
            address_line2: '',
            address_line3: '',
            address_line4: '',
            postcode: '',
            country: 'NL',
            email: '',
          },
          course: course_json,
          qualifications: {
            gcses: [
              {
                qualification_type: '',
                subject: '',
                grade: '',
                award_year: '',
                equivalency_details: '',
                institution_details: '',
              },
            ],
            degrees: [
              {
                qualification_type: "",
                subject: "",
                grade: "",
                award_year: "",
                equivalency_details: "",
                institution_details: "",
              }
            ],
            other_qualifications: [
              {
                qualification_type: "",
                subject: "",
                grade: "",
                award_year: "",
                equivalency_details: "",
                institution_details: "",
              }
            ]
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
          further_information: '',
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
