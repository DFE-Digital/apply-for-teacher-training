require 'rails_helper'

RSpec.describe ApplicationDataService do
  describe 'gcse_qualifications_summary' do
    it 'returns a summary of maths, science and english GCSEs for an application form' do
      application_form = create(:completed_application_form, with_gcses: true)

      summary = described_class.gcse_qualifications_summary(application_form: application_form)

      expect(summary).to include('Gcse Maths', 'Gcse Science', 'Gcse English')
    end

    it 'does not include gcses in other subjects' do
      application_form = create(:completed_application_form, with_gcses: true)

      create(:application_qualification, level: :gcse, subject: :french, application_form: application_form)

      summary = described_class.gcse_qualifications_summary(application_form: application_form)

      expect(summary).not_to be_blank
      expect(summary).not_to include('French')
    end

    it 'includes qualifications that are equivalent to gcses' do
      application_form = create(:completed_application_form)

      o_level = create(:application_qualification, level: :gcse, qualification_type: 'gce_o_level', subject: :maths, application_form: application_form)

      summary = described_class.gcse_qualifications_summary(application_form: application_form)

      expect(summary).to include('Gce o level Maths', o_level.grade)
    end

    it 'returns nil if a form has no relevant gcses' do
      application_form = create(:completed_application_form)

      summary = described_class.gcse_qualifications_summary(application_form: application_form)

      expect(summary).to be_nil
    end
  end

  describe 'missing_gcses_explanation' do
    it 'returns a list of a candidate’s missing gcses, with reasons' do
      application_form = create(:completed_application_form)
      missing_gcse = create(:gcse_qualification, :missing, subject: :maths, application_form: application_form)

      explanation = described_class.missing_gcses_explanation(application_form: application_form)

      expect(explanation).to include('Maths GCSE or equivalent', missing_gcse.missing_explanation)
    end

    it 'returns nil if a form has no missing gcses' do
      application_form = create(:completed_application_form, with_gcses: true)

      explanation = described_class.missing_gcses_explanation(application_form: application_form)

      expect(explanation).to be_nil
    end
  end
end
