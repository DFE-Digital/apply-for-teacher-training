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
        .to change { Provider.count }.by(11)
        .and change { Course.count }.by(130)
    end

    it 'generates courses' do
      described_class.call

      expect(Provider.find_by(code: 'B35').courses.count).to eq(10)
    end

    it 'generates ratified courses' do
      described_class.call

      expect(Provider.find_by(code: 'B35').accredited_courses.count).to eq(3)
    end
  end
end
