require 'rails_helper'

RSpec.describe DataMigrations::BackfillRestucturedWorkHistoryBoolean do
  context 'when `feature_restructured_work_history` is true' do
    it 'sets `feature_restructured_work_history` to false if jobs or an explanation have been provided' do
      application_form_with_jobs = create(:application_form, feature_restructured_work_history: true)
      create(:application_work_experience, application_form: application_form_with_jobs)
      application_form_with_explanation = create(
        :application_form, work_history_explanation: 'I left school and have travelled, then went to uni.',
                           feature_restructured_work_history: true
      )
      application_form_with_no_jobs_or_explanation = create(:application_form, feature_restructured_work_history: true)

      described_class.new.change

      expect(application_form_with_jobs.reload.feature_restructured_work_history).to eq false
      expect(application_form_with_explanation.reload.feature_restructured_work_history).to eq false
      expect(application_form_with_no_jobs_or_explanation.reload.feature_restructured_work_history).to eq true
    end
  end

  context 'when `feature_restructured_work_history` is false' do
    it 'sets `feature_restructured_work_history` to true if no jobs or an explanation have been provided' do
      application_form_with_jobs = create(:application_form, feature_restructured_work_history: false)
      create(:application_work_experience, application_form: application_form_with_jobs)
      application_form_with_explanation = create(
        :application_form, work_history_explanation: 'I left school and have travelled, then went to uni.',
                           feature_restructured_work_history: false
      )
      application_form_with_no_jobs_or_explanation = create(:application_form, feature_restructured_work_history: false)

      described_class.new.change

      expect(application_form_with_jobs.reload.feature_restructured_work_history).to eq false
      expect(application_form_with_explanation.reload.feature_restructured_work_history).to eq false
      expect(application_form_with_no_jobs_or_explanation.reload.feature_restructured_work_history).to eq true
    end
  end
end
