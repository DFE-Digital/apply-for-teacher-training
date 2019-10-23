require 'rails_helper'

RSpec.describe VendorApi::SingleApplicationPresenter do
  subject(:presenter) { described_class.new(application_choice) }

  around do |example|
    Timecop.freeze do
      example.run
    end
  end

  describe '#as_json' do
    def json
      @json ||= presenter.as_json.deep_symbolize_keys
    end

    def application_choice
      @application_choice ||= create(:application_choice)
    end

    def expected_attributes
      {
        id: application_choice.id.to_s,
        type: 'application',
        attributes: {
          personal_statement: application_choice.personal_statement,
          hesa_itt_data: {
            disability: '',
            ethnicity: '',
            sex: '',
          },
          offer: nil,
          contact_details: {
            address_line1: '',
            address_line2: '',
            address_line3: '',
            address_line4: '',
            postcode: '',
            country: 'NL',
            phone_number: '',
            email: '',
          },
          course: {
            start_date: application_choice.course.start_date,
            provider_ucas_code: application_choice.provider.code,
            site_ucas_code: application_choice.course_option.site.code,
            course_ucas_code: application_choice.course.code,
          },
          candidate: {
            first_name: application_choice.application_form.first_name,
            last_name: application_choice.application_form.last_name,
            date_of_birth: application_choice.application_form.date_of_birth,
            nationality: %w[NL],
            uk_residency_status: '',
            english_main_language: true,
            english_language_qualifications: '',
            other_languages: '',
          },
          qualifications: [],
          references: [],
          rejection: nil,
          status: application_choice.status,
          submitted_at: Time.now,
          updated_at: application_choice.updated_at,
          withdrawal: nil,
          work_experiences: [],
          further_information: '',
        }
      }
    end

    it 'returns correct application attributes' do
      expect(json).to eq expected_attributes
    end
  end
end
