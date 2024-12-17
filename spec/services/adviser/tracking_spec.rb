require 'rails_helper'

RSpec.describe Adviser::Tracking do
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

  describe '.candidate_signed_up_for_adviser' do
    before { tracker.candidate_signed_up_for_adviser }

    it 'enqueues a candidate_signed_up_for_adviser event' do
      expect(:candidate_signed_up_for_adviser).to have_been_enqueued_as_analytics_events
    end
  end

  describe '.candidate_offered_adviser' do
    before { tracker.candidate_offered_adviser }

    it 'enqueues a candidate_offered_adviser event' do
      expect(:candidate_offered_adviser).to have_been_enqueued_as_analytics_events
    end
  end
end
