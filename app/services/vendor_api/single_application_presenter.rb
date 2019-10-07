module VendorApi
  class SingleApplicationPresenter
    attr_reader :application_choice

    def initialize(application_choice)
      @application_choice = application_choice
    end

    def as_json
      {
        id: SecureRandom.hex[0..9],
        type: 'application',
        attributes: {
          status: application_choice.status || 'application_complete',
          updated_at: application_choice.updated_at,
          submitted_at: Time.now,
          personal_statement: 'hello',
          candidate: {
            first_name: '',
            last_name: '',
            date_of_birth: '2019-01-01',
            nationality: %w[NL],
            uk_residency_status: '',
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
          course: {
            start_date: 'ad',
            provider_ucas_code: application_choice.provider_ucas_code,
            location_ucas_code: 'x',
            course_ucas_code: 'x',
          },
          qualifications: [],
          references: [],
          work_experiences: [],
          offer: application_choice.offer,
          rejection: nil,
          withdrawal: nil,
          hesa_itt_data: {
            sex: '',
            disability: '',
            ethnicity: '',
          },
        },
      }
    end
  end
end
