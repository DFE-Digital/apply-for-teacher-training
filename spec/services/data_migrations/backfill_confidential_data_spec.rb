require 'rails_helper'

RSpec.describe DataMigrations::BackfillConfidentialData do
  subject(:data_migration) { described_class.new.change }

  context 'references is not for a 2025 application form' do
    let(:application_form) { create(:application_form, recruitment_cycle_year: 2024) }

    it 'does not change the confidential status' do
      reference = create(:application_reference, confidential: nil, feedback_status: 'feedback_provided', application_form:)
      data_migration
      expect(reference.reload.confidential).to be_nil
    end
  end

  context 'reference is a status other than feedback_provided' do
    let(:application_form) { create(:application_form, recruitment_cycle_year: 2025) }

    it 'does not change the confidential status' do
      feedback_status = %w[cancelled cancelled_at_end_of_cycle not_requested_yet feedback_requested feedback_refused email_bounced].sample
      reference = create(:application_reference, confidential: nil, feedback_status:, application_form:)
      data_migration
      expect(reference.reload.confidential).to be_nil
    end
  end

  context 'references has a true value for confidential' do
    let(:application_form) { create(:application_form, recruitment_cycle_year: 2025) }

    it 'does not change the confidential status' do
      reference = create(:application_reference, confidential: false, feedback_status: 'feedback_provided', application_form:)
      data_migration
      expect(reference.reload.confidential).to be false
    end
  end

  context 'reference is from 2025, feedback has been provided, and does not have a confidential status' do
    let(:application_form) { create(:application_form, recruitment_cycle_year: 2025) }

    it 'updates the confidential status to true' do
      reference = create(:application_reference, confidential: nil, feedback_status: 'feedback_provided', application_form:)
      data_migration
      expect(reference.reload.confidential).to be true
    end
  end
end
