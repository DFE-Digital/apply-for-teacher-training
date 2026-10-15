require 'rails_helper'

RSpec.describe CandidateInterface::Steps::PreferencesWizard::LocationPreferenceList, type: :model do
  subject(:step) { described_class.new }

  let(:location_preferences) { [] }

  describe 'validations' do
    before do
      allow(step).to receive(:wizard).and_return(instance_double(CandidateInterface::PreferencesWizard, location_preferences:))
    end

    context 'when no location preferences have been set' do
      it 'is invalid' do
        expect(step).not_to be_valid
        expect(step.errors.full_messages).to eq(
         ['Add an area you can train in'],
       )
      end
    end

    context 'when location preferences have been set' do
      let(:location_preferences) { [{within: 10, uid: 'abc123', location_name: 'London'}] }

      it 'is valid' do
        expect(step).to be_valid
      end
    end
  end
end
