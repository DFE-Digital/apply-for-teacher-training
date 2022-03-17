require 'rails_helper'

RSpec.describe ApplicationChoiceExportDecorator do
  describe 'gcse_qualifications_summary' do
    it 'returns a summary of maths, science and english GCSEs for an application form' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, application_form: application_form)
      create(:gcse_qualification, application_form: application_form, subject: 'maths', grade: 'A', award_year: '2000')
      create(:gcse_qualification, :multiple_english_gcses, application_form: application_form, award_year: '2000', constituent_grades: { english_language: { grade: 'B', public_id: 120282 }, english_literature: { grade: 'C', public_id: 120283 } })
      create(:gcse_qualification, :science_gcse, application_form: application_form, subject: 'science double award', grade: 'AB', award_year: '2000')

      summary = described_class.new(application_choice).gcse_qualifications_summary

      expect(summary).to match('Gcse Maths, A, 2000,Gcse English, B (English Language) C (English Literature), 2000,Gcse Science double award, AB (Double award), 2000')
    end

    it 'returns the gcse start year if present' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, application_form: application_form)
      create(:application_qualification, qualification_type: :gcse, level: :gcse, start_year: '2005', award_year: '2006', subject: :maths, application_form: application_form)

      summary = described_class.new(application_choice).gcse_qualifications_summary

      expect(summary).to match(/^Gcse Maths, [ABCD], \d{4}-\d{4}$/)
    end

    it 'does not include gcses in other subjects' do
      application_form = create(:application_form, :with_gcses)
      application_choice = create(:application_choice, application_form: application_form)
      create(:application_qualification, level: :gcse, subject: :french, application_form: application_form)

      summary = described_class.new(application_choice).gcse_qualifications_summary

      expect(summary).not_to be_blank
      expect(summary).not_to include('French')
    end

    it 'includes qualifications that are equivalent to gcses' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, application_form: application_form)
      o_level = create(:application_qualification, level: :gcse, qualification_type: 'gce_o_level', subject: :maths, application_form: application_form)

      summary = described_class.new(application_choice).gcse_qualifications_summary

      expect(summary).to include('Gce o level Maths', o_level.grade)
    end

    it 'returns nil if a form has no relevant gcses' do
      application_form = create(:completed_application_form)
      application_choice = create(:application_choice, application_form: application_form)

      summary = described_class.new(application_choice).gcse_qualifications_summary

      expect(summary).to be_nil
    end
  end

  describe 'missing_gcses_explanation' do
    it 'returns a list of a candidate’s missing gcses, with reasons' do
      application_form = create(:completed_application_form)
      application_choice = create(:application_choice, application_form: application_form)
      missing_gcse = create(:gcse_qualification, :missing_and_currently_completing, subject: :maths, application_form: application_form)

      explanation = described_class.new(application_choice).missing_gcses_explanation

      expect(explanation).to include('Maths GCSE or equivalent', missing_gcse.not_completed_explanation)
    end

    it 'returns nil if a form has no missing gcses' do
      application_form = create(:application_form, :with_gcses)
      application_choice = create(:application_choice, application_form: application_form)

      explanation = described_class.new(application_choice).missing_gcses_explanation

      expect(explanation).to be_nil
    end
  end

  describe 'degrees_completed_flag' do
    it 'returns 1 if the degrees section of the application form has been completed' do
      application_form = create(:completed_application_form)
      application_choice = create(:application_choice, application_form: application_form)

      result = described_class.new(application_choice).degrees_completed_flag

      expect(result).to eq(1)
    end

    it 'returns 0 if the degrees section of the application form has not been completed' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, application_form: application_form)

      result = described_class.new(application_choice).degrees_completed_flag

      expect(result).to eq(0)
    end
  end

  describe 'nationalities' do
    it 'returns an array of 2 letter country codes corresponding to the candidate’s nationalities' do
      application_form = create(:application_form, first_nationality: 'British')
      application_choice = create(:application_choice, application_form: application_form)

      result = described_class.new(application_choice).nationalities

      expect(result).to eq(%w[GB])
    end

    it 'sorts nationalities alphabetically' do
      application_form = create(:application_form, first_nationality: 'American', second_nationality: 'Turkish')
      application_choice = create(:application_choice, application_form: application_form)

      result = described_class.new(application_choice).nationalities

      expect(result).to eq(%w[TR US])
    end

    it 'sorts nationalities alphabetically and puts British and Irish first' do
      application_form = create(:application_form, first_nationality: 'American', second_nationality: 'British', third_nationality: 'Irish')
      application_choice = create(:application_choice, application_form: application_form)

      result = described_class.new(application_choice).nationalities

      expect(result).to eq(%w[GB IE US])
    end
  end
end
