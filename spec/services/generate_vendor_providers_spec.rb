require 'rails_helper'

RSpec.describe GenerateVendorProviders do
  describe '#call' do
    it 'raises an error in production' do
      ClimateControl.modify HOSTING_ENVIRONMENT_NAME: 'production' do
        expect { described_class.call }.to raise_error(RuntimeError, 'You can\'t generate test data in production')
      end
    end

    it 'generates provider vendor data' do
      expect { described_class.call }
        .to change { Provider.count }.by(10)
    end
  end
end
