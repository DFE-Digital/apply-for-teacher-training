require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationDataExport do
  around do |example|
    Timecop.freeze do
      example.run
    end
  end

  describe '#call' do
    it 'returns no rows if there are no applications passed in' do
      exported_data = CSV.parse(described_class.call(application_choices: []), headers: true)
      expect(exported_data.first).to be_nil
    end

    it 'returns data for application_choices with a completed form and a degree' do
      application_form_with_degree = create(:completed_application_form, :with_degree)
      choice = create(:application_choice, application_form: application_form_with_degree)

      exported_data = CSV.parse(described_class.call(application_choices: choice), headers: true)
      row = exported_data.first

      expect_row_to_match_application_choice(row, choice)
    end

    def expect_row_to_match_application_choice(row, application_choice)
      first_degree = application_choice.application_form.application_qualifications
                       .order(created_at: :asc)
                       .find_by(level: 'degree')

      expected = {
        'application_choice_id' => application_choice.id.to_s,
        'support_reference' => application_choice.application_form.support_reference,
        'status' => application_choice.status,
        'submitted_at' => application_choice.application_form.submitted_at&.to_s,
        'updated_at' => application_choice.updated_at&.to_s,
        'recruited_at' => application_choice.recruited_at&.to_s,
        'rejection_reason' => application_choice.rejection_reason,
        'rejected_at' => application_choice.rejected_at&.to_s,
        'reject_by_default_at' => application_choice.reject_by_default_at&.to_s,
        'first_name' => application_choice.application_form.first_name,
        'last_name' => application_choice.application_form.last_name,
        'date_of_birth' => application_choice.application_form.date_of_birth&.to_s,
        'nationality' => 'GB US',
        'domicile' => application_choice.application_form.domicile,
        'uk_residency_status' => application_choice.application_form.uk_residency_status,
        'english_main_language' => application_choice.application_form.english_main_language&.to_s,
        'english_language_qualifications' => application_choice.application_form.english_language_details,
        'email' => application_choice.application_form.candidate.email_address,
        'phone_number' => application_choice.application_form.phone_number,
        'address_line1' => application_choice.application_form.address_line1,
        'address_line2' => application_choice.application_form.address_line2,
        'address_line3' => application_choice.application_form.address_line3,
        'address_line4' => application_choice.application_form.address_line4,
        'postcode' => application_choice.application_form.postcode,
        'country' => application_choice.application_form.country,
        'recruitment_cycle_year' => application_choice.application_form.recruitment_cycle_year&.to_s,
        'provider_code' => application_choice.provider.code,
        'accredited_provider_name' => application_choice.accredited_provider&.name,
        'accredited_provider_code' => application_choice.accredited_provider&.code,
        'course_code' => application_choice.course.code,
        'site_code' => application_choice.site.code,
        'study_mode' => application_choice.course.study_mode,
        'start_date' => application_choice.course.start_date&.to_s,
        'FIRSTDEG' => application_choice.application_form.degrees_completed ? '1' : '0',
        'qualification_type' => first_degree&.qualification_type,
        'non_uk_qualification_type' => first_degree&.non_uk_qualification_type,
        'subject' => first_degree&.subject,
        'grade' => first_degree&.grade,
        'start_year' => first_degree&.start_year,
        'award_year' => first_degree&.award_year,
        'institution_details' => first_degree&.institution_name,
        'equivalency_details' => first_degree&.equivalency_details,
        'awarding_body' => first_degree&.awarding_body,
        'gcse_qualifications_summary' => nil,
        'missing_gcses_explanation' => nil,
        'disability_disclosure' => application_choice.application_form.disability_disclosure,
      }

      expected.each do |key, expected_value|
        expect(row[key]).to eq(expected_value), "Expected #{key} to eq (#{expected_value.class}) #{expected_value}, got (#{row[key].class}) #{row[key]} instead"
      end
    end
  end
end
