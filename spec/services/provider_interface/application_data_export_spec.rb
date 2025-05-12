require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationDataExport do
  describe '.export_row' do
    let(:exported_row) { described_class.export_row(application_choice) }

    context 'when there are no application_choice choices' do
      let(:application_choice) { nil }

      it 'returns no rows' do
        expect(exported_row).to be_empty
      end
    end

    context 'when there are application choices' do
      let(:application_choice) { create(:application_choice, :offered, application_form:) }
      let!(:maths_gcse) { create(:gcse_qualification, application_form:, subject: 'maths', grade: 'B', award_year: 2019) }
      let!(:english_gcse) { create(:gcse_qualification, application_form:, subject: 'english', grade: 'A', award_year: 2019) }

      context 'with a completed form and a degree' do
        let(:application_form) { create(:completed_application_form, :with_degree) }

        it 'returns the correct data' do
          expect_row_to_match_application_choice(exported_row, application_choice)
        end
      end

      context 'without a degree' do
        let(:application_form) { create(:completed_application_form, degrees_completed: false) }

        it 'returns the correct data' do
          expect_row_to_match_application_choice(exported_row, application_choice)
        end
      end
    end

    context 'when the application choice is inactive' do
      let(:application_choice) { create(:application_choice, :inactive) }

      it 'returns the status as received' do
        expect(exported_row['Status']).to eq 'Received'
      end
    end

    context 'when composite_equivalency_details is present' do
      let(:application_choice) { create(:application_choice, :offered, application_form:) }
      let(:application_form) do
        create(
          :completed_application_form,
          application_qualifications: [
            create(
              :application_qualification,
              enic_reference: '4000123456',
              level: :degree,
            ),
          ],
        )
      end

      it 'returns the correct data' do
        expect(exported_row['Equivalency details for international degree']).to eq(
          'ENIC: 4000123456',
        )
      end
    end

    def expect_row_to_match_application_choice(row, application_choice)
      first_degree = application_choice.application_form.application_qualifications
                       .order(created_at: :asc)
                       .find_by(level: 'degree')
      expected = {
        'Application number' => application_choice.id,
        'Recruitment cycle' => application_choice.application_form.recruitment_cycle_timetable.cycle_range_name,
        'Status' => I18n.t("provider_application_states.#{application_choice.status}", default: application_choice.status),
        'Received date' => application_choice.sent_to_provider_at,
        'Updated date' => application_choice.updated_at,
        'First name' => application_choice.application_form.first_name,
        'Last name' => application_choice.application_form.last_name,
        'Date of birth' => application_choice.application_form.date_of_birth,
        'Nationality' => 'United Kingdom, United States',
        'Nationality code' => 'GB US',
        'Disability support request' => application_choice.application_form.disability_disclosure,
        'Email address' => application_choice.application_form.candidate.email_address,
        'Phone number' => application_choice.application_form.phone_number,
        'Contact address line 1' => application_choice.application_form.address_line1,
        'Contact address line 2' => application_choice.application_form.address_line2,
        'Contact address line 3' => application_choice.application_form.address_line3,
        'Contact address line 4' => application_choice.application_form.address_line4,
        'Contact postcode' => application_choice.application_form.postcode,
        'Contact country' => 'United Kingdom',
        'Contact country code' => 'GB',
        'Domicile' => DomicileResolver.country_for_hesa_code(application_choice.application_form.domicile),
        'Domicile code' => application_choice.application_form.domicile,
        'English is main language' => 'TRUE',
        'English as a foreign language assessment details' => application_choice.application_form.english_language_details,
        'Course' => application_choice.current_course.name,
        'Course code' => application_choice.current_course.code,
        'Training provider' => application_choice.current_provider.name,
        'Training provider code' => application_choice.current_provider.code,
        'Accredited body' => application_choice.current_accredited_provider&.name,
        'Accredited body code' => application_choice.current_accredited_provider&.code,
        'Location' => application_choice.current_site.name,
        'Location code' => application_choice.current_site.code,
        'Full time or part time' => 'Full time',
        'Course start date' => application_choice.current_course.start_date,
        'Has degree' => application_choice.application_form.degrees_completed ? 'TRUE' : 'FALSE',
        'Type of degree' => first_degree&.qualification_type,
        'Subject of degree' => first_degree&.subject,
        'Grade of degree' => first_degree&.grade,
        'Start year of degree' => first_degree&.start_year,
        'Award year of degree' => first_degree&.award_year,
        'Institution of degree' => first_degree&.institution_name,
        'Equivalency details for international degree' => first_degree&.composite_equivalency_details,
        'Type of international degree' => first_degree&.non_uk_qualification_type,
        'GCSEs' => 'GCSE maths, B, 2019; GCSE English, A, 2019',
        'Explanation for missing GCSEs' => nil,
        'Offered date' => application_choice.offered_at,
        'Recruited date' => application_choice.recruited_at,
        'Rejected date' => application_choice.rejected_at,
        'Rejection reasons' => ApplicationChoiceExportDecorator.new(application_choice).rejection_reasons,
        'Candidate ID' => application_choice.application_form.candidate.public_id,
        'Support reference' => application_choice.application_form.support_reference,
        'Offer accepted date' => application_choice.accepted_at,
        'Withdrawn date' => application_choice.withdrawn_at,
        'Declined date' => application_choice.declined_at,
      }

      expected.each do |key, expected_value|
        if key == 'Equivalency details for international degree'
          expect(row[key]).to be_blank
        else
          expect(row[key]).to eq(expected_value), "Expected #{key} to eq (#{expected_value.class}) #{expected_value}, got (#{row[key].class}) #{row[key]} instead"
        end
      end
    end
  end

  describe '.replace_smart_quotes' do
    it 'replaces smart quotes in text' do
      expect(described_class.replace_smart_quotes(%(“double-quote” ‘single-quote’))).to eq(%("double-quote" 'single-quote'))
    end
  end
end
