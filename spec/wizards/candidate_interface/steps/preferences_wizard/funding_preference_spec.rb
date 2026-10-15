require 'rails_helper'

RSpec.describe CandidateInterface::Steps::PreferencesWizard::FundingPreference, type: :model do
  describe 'attributes' do
    it 'has attributes associated with the form' do
      expect(described_class.new).to have_attributes(funding_type: nil)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_inclusion_of(:funding_type).in_array %w[fee salary] }
  end

  describe '#permitted_params' do
    it 'returns the permitted_params' do
      expect(described_class.permitted_params).to contain_exactly(:funding_type)
    end
  end
end
