require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationDataExport do
  around do |example|
    Timecop.freeze do
      example.run
    end
  end

  describe '.export_row' do
    let(:exported_row) { described_class.export_row(application_choice) }

    context 'when there are no application choices' do
      let(:application_choice) { nil }

      it 'returns no rows' do
        expect(exported_row).to be_empty
      end
    end

    context 'when there are application choices with a completed form and a degree' do
      let(:application_form) { create(:completed_application_form, :with_degree) }
      let(:application_choice) { create(:application_choice, :with_modified_offer, application_form: application_form) }

      it 'returns the correct data' do
        expect_row_to_match_application_choice(exported_row, application_choice)
      end
    end

    context 'when there are application choices without a degree' do
      let(:application_form) { create(:completed_application_form, degrees_completed: false) }
      let(:application_choice) { create(:application_choice, :with_modified_offer, application_form: application_form) }

      it 'returns the correct data' do
        expect_row_to_match_application_choice(exported_row, application_choice)
      end
    end

    def expect_row_to_match_application_choice(row, application_choice)
      first_degree = application_choice.application_form.application_qualifications
                       .order(created_at: :asc)
                       .find_by(level: 'degree')
      expected = {
        'application_choice_id' => application_choice.id,
        'candidate_id' => application_choice.application_form.candidate.public_id,
        'support_reference' => application_choice.application_form.support_reference,
        'status' => application_choice.status,
        'submitted_at' => application_choice.application_form.submitted_at,
        'updated_at' => application_choice.updated_at,
        'recruited_at' => application_choice.recruited_at,
        'rejection_reason' => application_choice.rejection_reason,
        'rejected_at' => application_choice.rejected_at,
        'reject_by_default_at' => application_choice.reject_by_default_at,
        'first_name' => application_choice.application_form.first_name,
        'last_name' => application_choice.application_form.last_name,
        'date_of_birth' => application_choice.application_form.date_of_birth,
        'nationality' => 'GB US',
        'domicile' => application_choice.application_form.domicile,
        'uk_residency_status' => application_choice.application_form.uk_residency_status,
        'english_main_language' => application_choice.application_form.english_main_language,
        'english_language_qualifications' => application_choice.application_form.english_language_details,
        'email' => application_choice.application_form.candidate.email_address,
        'phone_number' => application_choice.application_form.phone_number,
        'address_line1' => application_choice.application_form.address_line1,
        'address_line2' => application_choice.application_form.address_line2,
        'address_line3' => application_choice.application_form.address_line3,
        'address_line4' => application_choice.application_form.address_line4,
        'postcode' => application_choice.application_form.postcode,
        'country' => application_choice.application_form.country,
        'recruitment_cycle_year' => application_choice.application_form.recruitment_cycle_year,
        'provider_code' => application_choice.current_provider.code,
        'accredited_provider_name' => application_choice.current_accredited_provider&.name,
        'accredited_provider_code' => application_choice.current_accredited_provider&.code,
        'course_code' => application_choice.current_course.code,
        'site_code' => application_choice.current_site.code,
        'study_mode' => application_choice.current_course.study_mode,
        'start_date' => application_choice.current_course.start_date,
        'FIRSTDEG' => application_choice.application_form.degrees_completed ? 1 : 0,
        'qualification_type' => first_degree&.qualification_type,
        'non_uk_qualification_type' => first_degree&.non_uk_qualification_type,
        'subject' => first_degree&.subject,
        'grade' => first_degree&.grade,
        'start_year' => first_degree&.start_year,
        'award_year' => first_degree&.award_year,
        'institution_details' => first_degree&.institution_name,
        'equivalency_details' => first_degree&.equivalency_details,
        'awarding_body' => nil,
        'gcse_qualifications_summary' => nil,
        'missing_gcses_explanation' => nil,
        'disability_disclosure' => application_choice.application_form.disability_disclosure,
      }

      expected.each do |key, expected_value|
        expect(row[key]).to eq(expected_value), "Expected #{key} to eq (#{expected_value.class}) #{expected_value}, got (#{row[key].class}) #{row[key]} instead"
      end
    end
  end

  describe 'replace_smart_quotes' do
    it 'replaces smart quotes in text' do
      expect(described_class.replace_smart_quotes(%(“double-quote” ‘single-quote’))).to eq(%("double-quote" 'single-quote'))
    end
  end
end
