require 'rails_helper'

RSpec.describe ApplicationChoiceExportDecorator do
  describe 'gcse_qualifications_summary' do
    it 'returns a summary of maths, science and english GCSEs for an application form' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, application_form:)
      create(:gcse_qualification, application_form:, subject: 'maths', grade: 'A', award_year: '2000')
      create(:gcse_qualification, :multiple_english_gcses, application_form:, award_year: '2000', constituent_grades: { english_language: { grade: 'B', public_id: 120282 }, english_literature: { grade: 'C', public_id: 120283 } })
      create(:gcse_qualification, :science_gcse, application_form:, subject: 'science double award', grade: 'AB', award_year: '2000')

      summary = described_class.new(application_choice).gcse_qualifications_summary

      expect(summary).to match('GCSE maths, A, 2000; GCSE English, B (English language) C (English literature), 2000; GCSE science double award, AB (double award), 2000')
    end

    it 'returns the GCSE start year if present' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, application_form:)
      create(:application_qualification, qualification_type: :gcse, level: :gcse, start_year: '2005', award_year: '2006', subject: :maths, application_form:)

      summary = described_class.new(application_choice).gcse_qualifications_summary

      expect(summary).to match(/^GCSE maths, [ABCD], \d{4} to \d{4}$/)
    end

    it 'does not include GCSEs in other subjects' do
      application_form = create(:application_form, :with_gcses)
      application_choice = create(:application_choice, application_form:)
      create(:application_qualification, level: :gcse, subject: :french, application_form:)

      summary = described_class.new(application_choice).gcse_qualifications_summary

      expect(summary).not_to be_blank
      expect(summary).not_to include('French')
    end

    it 'includes qualifications that are equivalent to GCSEs' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, application_form:)
      o_level = create(:application_qualification, level: :gcse, qualification_type: 'gce_o_level', subject: :maths, application_form:)

      summary = described_class.new(application_choice).gcse_qualifications_summary

      expect(summary).to include('O level maths', o_level.grade)
    end

    it 'returns nil if a form has no relevant GCSEs' do
      application_form = create(:completed_application_form)
      application_choice = create(:application_choice, application_form:)

      summary = described_class.new(application_choice).gcse_qualifications_summary

      expect(summary).to be_nil
    end

    it 'formats default qualification types' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, application_form:)
      create(
        :gcse_qualification,
        qualification_type: 'non_uk',
        grade: 'A',
        subject: 'maths',
        award_year: 2014,
        application_form:,
      )
      create(
        :gcse_qualification,
        qualification_type: 'other_uk',
        grade: 'B',
        subject: 'english',
        application_form:,
        award_year: 2014,
      )

      summary = described_class.new(application_choice).gcse_qualifications_summary

      expect(summary).to eq('Non-UK maths, A, 2014; Other UK English, B, 2014')
    end
  end

  describe 'missing_gcses_explanation' do
    it 'returns a list of a candidate’s missing gcses, with reasons' do
      application_form = create(:completed_application_form)
      application_choice = create(:application_choice, application_form:)
      missing_gcse = create(:gcse_qualification, :missing_and_currently_completing, subject: :maths, application_form:)

      explanation = described_class.new(application_choice).missing_gcses_explanation

      expect(explanation).to include('Maths GCSE or equivalent', missing_gcse.not_completed_explanation)
    end

    it 'returns nil if a form has no missing GCSEs' do
      application_form = create(:application_form, :with_gcses)
      application_choice = create(:application_choice, application_form:)

      explanation = described_class.new(application_choice).missing_gcses_explanation

      expect(explanation).to be_nil
    end
  end

  describe 'degrees_completed_flag' do
    it 'returns 1 if the degrees section of the application form has been completed' do
      application_form = create(:completed_application_form)
      application_choice = create(:application_choice, application_form:)

      result = described_class.new(application_choice).degrees_completed_flag

      expect(result).to eq(1)
    end

    it 'returns 0 if the degrees section of the application form has not been completed' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, application_form:)

      result = described_class.new(application_choice).degrees_completed_flag

      expect(result).to eq(0)
    end
  end

  describe 'nationalities' do
    it 'returns an array of 2 letter country codes corresponding to the candidate’s nationalities' do
      application_form = create(:application_form, first_nationality: 'British')
      application_choice = create(:application_choice, application_form:)

      result = described_class.new(application_choice).nationalities

      expect(result).to eq(%w[GB])
    end

    it 'sorts nationalities alphabetically' do
      application_form = create(:application_form, first_nationality: 'American', second_nationality: 'Turk, Turkish')
      application_choice = create(:application_choice, application_form:)

      result = described_class.new(application_choice).nationalities

      expect(result).to eq(%w[TR US])
    end

    it 'sorts nationalities alphabetically and puts British and Irish first' do
      application_form = create(:application_form, first_nationality: 'American', second_nationality: 'British', third_nationality: 'Irish')
      application_choice = create(:application_choice, application_form:)

      result = described_class.new(application_choice).nationalities

      expect(result).to eq(%w[GB IE US])
    end
  end

  describe '.rejection_reasons' do
    let(:application_choice) { create(:application_choice, :with_old_structured_rejection_reasons) }

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

      expect(described_class.new(application_choice).rejection_reasons.split("\n\n")).to eq(expected)
    end

    context 'where the only reason is REASONS WHY YOUR APPLICATION WAS UNSUCCESSFUL' do
      it 'strips the reason heading' do
        presenter = instance_double(RejectedApplicationChoicePresenter)
        allow(presenter).to receive(:rejection_reasons).and_return({
          'reasons why your application was unsuccessful' => ["We don't accept applications written in invisible ink."],
        })
        allow(RejectedApplicationChoicePresenter).to receive(:new).and_return(presenter)
        expect(described_class.new(application_choice).rejection_reasons).to eq("We don't accept applications written in invisible ink.")
      end
    end
  end

  describe 'formatted_equivalency_details' do
    it 'translates comparable uk degrees' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, application_form:)
      create(:non_uk_degree_qualification, application_form:)

      summary = described_class.new(application_choice).formatted_equivalency_details

      expect(summary).to match(/^ENIC: \d+ - Bachelor's degree \(ordinary\)/)
    end
  end
end
