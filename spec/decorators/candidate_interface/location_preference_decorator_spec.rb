require 'rails_helper'

RSpec.describe CandidateInterface::LocationPreferenceDecorator do
  describe 'decorated_name' do
    context 'when provider is present' do
      it 'returns the provider in the name of the location preference' do
        provider = create(:provider)
        location_preference = create(:candidate_location_preference, provider:)

        decorator = described_class.new(location_preference)

        expect(decorator.decorated_name).to eq("#{location_preference.name} (#{provider.name})")
      end
    end

    context 'when provider is not present' do
      it 'returns the provider in the name of the location preference' do
        location_preference = build(:candidate_location_preference)

        decorator = described_class.new(location_preference)

        expect(decorator.decorated_name).to eq(location_preference.name)
      end
    end
  end
end
