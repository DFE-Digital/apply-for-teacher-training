require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  # rubocop:disable RSpec/AnyInstance
  describe '#service_key' do
    it 'is apply for candidate_interface namespace' do
      allow_any_instance_of(described_class).to receive(:current_namespace).and_return('candidate_interface')
      expect(service_key).to eq('apply')
    end

    it 'is manage for provider_interface namespace' do
      allow_any_instance_of(described_class).to receive(:current_namespace).and_return('provider_interface')
      expect(service_key).to eq('manage')
    end

    it 'is support for support_interface namespace' do
      allow_any_instance_of(described_class).to receive(:current_namespace).and_return('support_interface')
      expect(service_key).to eq('support')
    end

    it 'is api for api_docs namespace' do
      allow_any_instance_of(described_class).to receive(:current_namespace).and_return('api_docs')
      expect(service_key).to eq('api')
    end

    it 'is apply for nil namespace' do
      allow_any_instance_of(described_class).to receive(:current_namespace).and_return(nil)
      expect(service_key).to eq('apply')
    end
  end
  # rubocop:enable RSpec/AnyInstance
end
