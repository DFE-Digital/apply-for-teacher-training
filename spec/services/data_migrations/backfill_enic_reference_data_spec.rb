require 'rails_helper'

RSpec.describe DataMigrations::BackfillEnicReferenceData do
  context 'where naric_reference is nil' do
    it 'does not update the enic_reference column' do
      application_qualification = create(:application_qualification, naric_reference: nil, enic_reference: nil)

      described_class.new.change
      application_qualification.reload

      expect(application_qualification.naric_reference).to be_nil
      expect(application_qualification.enic_reference).to be_nil
    end
  end

  context 'where enic_reference is not nil' do
    it 'does not update the enic_reference column' do
      application_qualification = create(:application_qualification, naric_reference: nil, enic_reference: '123456')

      described_class.new.change
      application_qualification.reload

      expect(application_qualification.naric_reference).to be_nil
      expect(application_qualification.enic_reference).to eq('123456')
    end
  end

  context 'where naric_reference is not nil and enic_reference is nil' do
    it "updates the 'enic_reference' column" do
      application_qualification = create(:application_qualification, naric_reference: '123456', enic_reference: nil)

      described_class.new.change
      application_qualification.reload

      expect(application_qualification.naric_reference).to eq('123456')
      expect(application_qualification.enic_reference).to eq('123456')
    end
  end
end
