require 'rails_helper'

RSpec.describe ProviderInterface::Tracking do
  let(:current_user_double) { instance_double(Candidate, id: 1) }
  let(:request_double) do
    instance_double(ActionDispatch::Request,
                    uuid: SecureRandom.uuid,
                    user_agent: 'Chrome',
                    method: :get,
                    original_fullpath: '/path',
                    query_string: nil,
                    referer: nil,
                    headers: { 'X-REAL-IP' => '1.2.3.4' })
  end

  subject(:tracker) { described_class.new(current_user_double, request_double) }

  before { allow(DfE::Analytics).to receive(:enabled?).and_return(true) }

  describe '.provider_download_application' do
    before { tracker.provider_download_application }

    it 'enqueues a provider_download_application event' do
      expect(:provider_download_application).to have_been_enqueued_as_analytics_events
    end
  end

  describe '.provider_download_references' do
    before { tracker.provider_download_references }

    it 'enqueues a provider_download_references event' do
      expect(:provider_download_references).to have_been_enqueued_as_analytics_events
    end
  end
end
