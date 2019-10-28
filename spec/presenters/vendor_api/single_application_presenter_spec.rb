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
            phone_number: application_choice.application_form.phone_number,
            address_line1: application_choice.application_form.address_line1,
            address_line2: application_choice.application_form.address_line2,
            address_line3: application_choice.application_form.address_line3,
            address_line4: application_choice.application_form.address_line4,
            postcode: application_choice.application_form.postcode,
            country: 'UK',
            email: application_choice.application_form.candidate.email_address,
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
            uk_residency_status: application_choice.application_form.uk_residency_status,
            english_main_language: application_choice.application_form.english_main_language,
            english_language_qualifications: application_choice.application_form.english_language_details,
            other_languages: application_choice.application_form.other_language_details,
            disability_disclosure: application_choice.application_form.disability_disclosure,
          },
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
                qualification_type: 'A Level',
                subject: 'Chemistry',
                grade: 'B',
                award_year: '2004',
                equivalency_details: nil,
                institution_details: 'Harris Westminster Sixth Form	',
              },
            ],
          },
          references: [],
          rejection: nil,
          status: application_choice.status,
          submitted_at: application_choice.application_form.submitted_at,
          updated_at: application_choice.updated_at,
          withdrawal: nil,
          work_experiences: [],
          further_information: application_choice.application_form.further_information,
        },
      }
    end

    it 'returns correct application attributes' do
      expect(json).to eq expected_attributes
    end
  end
end
