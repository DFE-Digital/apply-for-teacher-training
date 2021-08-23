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

      expected = [
        application_choice.id,
        application_choice.application_form.candidate.public_id,
        application_choice.application_form.support_reference,
        application_choice.status,
        application_choice.application_form.submitted_at,
        application_choice.updated_at,
        application_choice.recruited_at,
        application_choice.rejection_reason,
        application_choice.rejected_at,
        application_choice.reject_by_default_at,
        application_choice.application_form.first_name,
        application_choice.application_form.last_name,
        application_choice.application_form.date_of_birth,
        'GB US',
        application_choice.application_form.domicile,
        application_choice.application_form.uk_residency_status,
        application_choice.application_form.english_main_language,
        application_choice.application_form.english_language_details,
        application_choice.application_form.candidate.email_address,
        application_choice.application_form.phone_number,
        application_choice.application_form.address_line1,
        application_choice.application_form.address_line2,
        application_choice.application_form.address_line3,
        application_choice.application_form.address_line4,
        application_choice.application_form.postcode,
        application_choice.application_form.country,
        application_choice.application_form.recruitment_cycle_year,
        application_choice.current_provider.code,
        application_choice.current_accredited_provider&.name,
        application_choice.current_accredited_provider&.code,
        application_choice.current_course.code,
        application_choice.current_site.code,
        application_choice.current_course_option.study_mode,
        application_choice.current_course.start_date,
        application_choice.application_form.degrees_completed ? 1 : 0,
        first_degree&.qualification_type,
        first_degree&.non_uk_qualification_type,
        first_degree&.subject,
        first_degree&.grade,
        first_degree&.start_year,
        first_degree&.award_year,
        first_degree&.institution_name,
        first_degree&.composite_equivalency_details,
        nil, # included for backwards compatibility. This column is always blank
        nil,
        nil,
        application_choice.application_form.disability_disclosure,
      ]

      expected.each_with_index do |expected_value, index|
        expect(row[index]).to eq(expected_value), "Expected value at #{index} to eq (#{expected_value.class}) #{expected_value}, got (#{row[index].class}) #{row[index]} instead"
      end
    end
  end

  describe 'replace_smart_quotes' do
    it 'replaces smart quotes in text' do
      expect(described_class.replace_smart_quotes(%(“double-quote” ‘single-quote’))).to eq(%("double-quote" 'single-quote'))
    end
  end
end
