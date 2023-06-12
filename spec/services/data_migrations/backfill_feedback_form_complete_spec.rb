require 'rails_helper'

RSpec.describe DataMigrations::BackfillFeedbackFormComplete do
  let!(:application_form) do
    create(:application_form,
           feedback_satisfaction_level: feedback_satisfaction_level,
           feedback_suggestions: feedback_suggestions)
  end

  subject(:data_migration) { described_class.new }

  context 'when application feedback fields are both filled out with feedback' do
    let(:feedback_satisfaction_level) { 'very_satisfied' }
    let(:feedback_suggestions) { 'some suggestions' }

    it 'sets feedback_form_complete to true' do
      data_migration.change

      expect(application_form.reload.feedback_form_complete).to be_truthy
    end
  end

  context 'when either application feedback fields are filled out with feedback' do
    let(:feedback_satisfaction_level) { 'very_satisfied' }
    let(:feedback_suggestions) { nil }

    it 'sets feedback_form_complete to true' do
      data_migration.change

      expect(application_form.reload.feedback_form_complete).to be_truthy
    end
  end

  context 'when any application feedback fields are filled with empty strings or nil' do
    let(:feedback_satisfaction_level) { '' }
    let(:feedback_suggestions) { nil }

    it 'does not update the feedback_form_complete flag to true' do
      data_migration.change

      expect(application_form.reload.feedback_form_complete).to be_falsey
    end
  end

  context 'when both application feedback fields are nil' do
    let(:feedback_satisfaction_level) { nil }
    let(:feedback_suggestions) { nil }

    it 'does not update the feedback_form_complete flag to true' do
      data_migration.change

      expect(application_form.reload.feedback_form_complete).to be_falsey
    end
  end
end
