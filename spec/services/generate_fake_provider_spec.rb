require 'rails_helper'

RSpec.describe GenerateFakeProvider do
  let(:provider_hash) { { name: 'Fake Provider', code: 'FAKE' } }

  subject(:generate_provider_call) { described_class.generate_provider(provider_hash) }

  describe '.generate_provider' do
    it 'raises an error in production' do
      ClimateControl.modify HOSTING_ENVIRONMENT_NAME: 'production' do
        expect { generate_provider_call }.to raise_error(RuntimeError, 'You can\'t generate test data in production')
      end
    end

    it 'generates a new provider and a test training provider for ratified courses' do
      expect { generate_provider_call }
        .to change { Provider.count }.by(2)
    end

    it 'generates courses run by the provider' do
      generate_provider_call

      expect(Provider.find_by(code: 'FAKE').courses.count).to eq(10)
    end

    it 'generates ratified courses' do
      generate_provider_call

      expect(Provider.find_by(code: 'FAKE').accredited_courses.count).to eq(3)
    end
  end
end
