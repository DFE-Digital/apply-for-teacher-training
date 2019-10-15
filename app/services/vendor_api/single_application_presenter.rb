module VendorApi
  class SingleApplicationPresenter
    def initialize(application_choice)
      @application_choice = application_choice
      @application_form = application_choice.application_form
    end

    def as_json
      {
        id: application_choice.id,
        type: 'application',
        attributes: {
          status: application_choice.status || 'application_complete',
          updated_at: application_choice.updated_at,
          submitted_at: Time.now,
          personal_statement: 'hello',
          candidate: {
            first_name: application_form.first_name,
            last_name: application_form.last_name,
            date_of_birth: application_form.date_of_birth,
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
          rejection: get_rejection,
          withdrawal: nil,
          hesa_itt_data: {
            sex: '',
            disability: '',
            ethnicity: '',
          },
        },
      }
    end

    def get_rejection
      if application_choice.rejection_reason?
        {
          reason: application_choice.rejection_reason,
          date: Time.now,
        }
      end
    end

  private

    attr_reader :application_choice, :application_form
  end
end
