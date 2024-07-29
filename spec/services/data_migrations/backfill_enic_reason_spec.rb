require 'rails_helper'

RSpec.describe DataMigrations::BackfillEnicReason do
  context 'when backfilling an applications qualifications enic_reason' do
    it 'backfills the enic_reason to obtained if enic_reference present' do
      application_qualification = create(:application_qualification, enic_reason: nil, enic_reference: '1234')
      described_class.new.change
      expect(application_qualification.enic_reason).to eq('obtained')
    end

    it 'backfills the enic_reason to maybe for a non_uk qualification if enic_reference nil' do
      application_qualification = create(:application_qualification, enic_reason: nil, enic_reference: nil, qualification_type: 'non_uk')
      described_class.new.change
      expect(application_qualification.enic_reason).to eq('maybe')
    end

    it 'backfills the enic_reason to not_needed if no enic_reference' do
      application_qualification = create(:application_qualification)
      described_class.new.change
      expect(application_qualification.enic_reason).to eq('not_needed')
    end
  end
end
