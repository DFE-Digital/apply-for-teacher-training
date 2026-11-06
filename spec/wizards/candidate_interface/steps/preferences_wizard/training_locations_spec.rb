require 'rails_helper'

RSpec.describe CandidateInterface::Steps::PreferencesWizard::TrainingLocations, type: :model do
  describe 'attributes' do
    it 'has attributes associated with the form' do
      expect(described_class.new).to have_attributes(training_locations: nil)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_inclusion_of(:training_locations).in_array %w[anywhere specific] }
  end

  describe '#permitted_params' do
    it 'returns the permitted_params' do
      expect(described_class.permitted_params).to contain_exactly(:training_locations)
    end
  end
end
