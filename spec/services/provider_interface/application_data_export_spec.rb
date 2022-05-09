require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationDataExport do
  around do |example|
    Timecop.freeze do
      example.run
    end
  end

  describe '.export_row' do
    let(:exported_row) { described_class.export_row(application_choice) }

    context 'when there are no application_choice choices' do
      let(:application_choice) { nil }

      it 'returns no rows' do
        expect(exported_row).to be_empty
      end
    end

    context 'when there are application_choice choices with a completed form and a degree' do
      let(:application_form) { create(:completed_application_form, :with_degree) }
      let(:application_choice) { create(:application_choice, :with_modified_offer, application_form: application_form) }

      it 'returns the correct data' do
        expect_row_to_match_application_choice(exported_row, application_choice)
      end
    end

    context 'when there are application_choice choices without a degree' do
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
        'Application number' => application_choice.id,
        'Recruitment cycle' => RecruitmentCycle.cycle_name(application_choice.application_form.recruitment_cycle_year),
        'Status' => I18n.t("provider_application_states.#{application_choice.status}", default: application_choice.status),
        'Received date' => application_choice.application_form.submitted_at,
        'Date for automatic rejection' => application_choice.reject_by_default_at,
        'Updated date' => application_choice.updated_at,
        'First name' => application_choice.application_form.first_name,
        'Last name' => application_choice.application_form.last_name,
        'Date of birth' => application_choice.application_form.date_of_birth,
        'Nationality code' => 'GB US',
        'Disability support request' => application_choice.application_form.disability_disclosure,
        'Email address' => application_choice.application_form.candidate.email_address,
        'Phone number' => application_choice.application_form.phone_number,
        'Contact address line 1' => application_choice.application_form.address_line1,
        'Contact address line 2' => application_choice.application_form.address_line2,
        'Contact address line 3' => application_choice.application_form.address_line3,
        'Contact address line 4' => application_choice.application_form.address_line4,
        'Contact postcode' => application_choice.application_form.postcode,
        'Contact country' => application_choice.application_form.country,
        'Domicile code' => application_choice.application_form.domicile,
        'Resident in UK' => application_choice.application_form.uk_residency_status,
        'English is main language' => application_choice.application_form.english_main_language,
        'English as a foreign language assessment details' => application_choice.application_form.english_language_details,
        'Course name' => application_choice.current_course.name,
        'Course code' => application_choice.current_course.code,
        'Training provider' => application_choice.current_provider.name,
        'Training provider code' => application_choice.current_provider.code,
        'Accredited body' => application_choice.current_accredited_provider&.name,
        'Accredited body code' => application_choice.current_accredited_provider&.code,
        'Location' => application_choice.current_site.name,
        'Location code' => application_choice.current_site.code,
        'Full time or part time' => application_choice.current_course_option.study_mode,
        'Course start date' => application_choice.current_course.start_date,
        'Has degree' => application_choice.application_form.degrees_completed ? 'TRUE' : 'FALSE',
        'Type of degree' => first_degree&.qualification_type,
        'Subject of degree' => first_degree&.subject,
        'Grade of degree' => first_degree&.grade,
        'Start year of degree' => first_degree&.start_year,
        'Award year of degree' => first_degree&.award_year,
        'Institution of degree' => first_degree&.institution_name,
        'Institution of international degree' => nil, # included for backwards compatibility. This column is always blank
        'Type of international degree' => first_degree&.non_uk_qualification_type,
        'Equivalency details for international degree' => first_degree&.composite_equivalency_details,
        'GCSEs' => nil,
        'Explanation for missing GCSEs' => nil,
        'Recruited date' => application_choice.recruited_at,
        'Rejected date' => application_choice.rejected_at,
        'Rejection reasons' => described_class.rejection_reasons(application_choice),
        'Candidate ID' => application_choice.application_form.candidate.public_id,
        'Support reference' => application_choice.application_form.support_reference,
      }

      expected.each do |key, expected_value|
        expect(row[key]).to eq(expected_value), "Expected #{key} to eq (#{expected_value.class}) #{expected_value}, got (#{row[key].class}) #{row[key]} instead"
      end
    end
  end

  describe '.replace_smart_quotes' do
    it 'replaces smart quotes in text' do
      expect(described_class.replace_smart_quotes(%(“double-quote” ‘single-quote’))).to eq(%("double-quote" 'single-quote'))
    end
  end

  describe '.rejection_reasons' do
    let(:application_choice) { create(:application_choice, :with_structured_rejection_reasons) }

    it 'returns a list of rejection reasons' do
      expected = ['SOMETHING YOU DID',
                  'Didn’t reply to our interview offer',
                  'Didn’t attend interview',
                  'Persistent scratching',
                  'Not scratch so much',
                  'QUALITY OF APPLICATION',
                  'Use a spellchecker',
                  "Claiming to be the 'world's leading expert' seemed a bit strong",
                  'Lights on but nobody home',
                  'Study harder',
                  'QUALIFICATIONS',
                  'No English GCSE grade 4 (C) or above, or valid equivalent',
                  'All the other stuff',
                  'PERFORMANCE AT INTERVIEW',
                  'Be fully dressed',
                  'HONESTY AND PROFESSIONALISM',
                  'Fake news',
                  'Clearly not a popular student',
                  'SAFEGUARDING ISSUES',
                  'We need to run further checks']

      expect(described_class.rejection_reasons(application_choice).split("\n\n")).to eq(expected)
    end
  end
end
