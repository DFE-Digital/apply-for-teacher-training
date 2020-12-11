require 'rails_helper'

RSpec.describe ApplicationChoiceExportDecorator do
  describe 'gcse_qualifications_summary' do
    it 'returns a summary of maths, science and english GCSEs for an application form' do
      application_form = create(:completed_application_form, with_gcses: true)
      application_choice = create(:application_choice, application_form: application_form)

      summary = described_class.new(application_choice).gcse_qualifications_summary

      expect(summary).to include('Gcse Maths', 'Gcse Science', 'Gcse English')
    end

    it 'does not include gcses in other subjects' do
      application_form = create(:completed_application_form, with_gcses: true)
      application_choice = create(:application_choice, application_form: application_form)
      create(:application_qualification, level: :gcse, subject: :french, application_form: application_form)

      summary = described_class.new(application_choice).gcse_qualifications_summary

      expect(summary).not_to be_blank
      expect(summary).not_to include('French')
    end

    it 'includes qualifications that are equivalent to gcses' do
      application_form = create(:completed_application_form)
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
      missing_gcse = create(:gcse_qualification, :missing, subject: :maths, application_form: application_form)

      explanation = described_class.new(application_choice).missing_gcses_explanation

      expect(explanation).to include('Maths GCSE or equivalent', missing_gcse.missing_explanation)
    end

    it 'returns nil if a form has no missing gcses' do
      application_form = create(:completed_application_form, with_gcses: true)
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
end
