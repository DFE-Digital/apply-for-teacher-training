require 'rails_helper'

RSpec.describe ProductionRecruitmentCycleTimetablesAPI::Client do
  let(:client) { described_class.new }
  let(:body) { Pathname.new(Rails.root.join(stub_body_path)) }

  describe '#fetch_recruitment_cycle' do
    context 'valid recruitment cycle year' do
      let(:stub_body_path) { 'spec/examples/production_recruitment_cycle_timetables_api/fetch_recruitment_cycle_2025.json' }

      before do
        stub_request(:get, [described_class::BASE_URL, 2025].join('/'))
          .to_return(
            status: 200,
            body: body.read,
            headers: { 'Content-Type' => 'application/json' },
          )
      end

      it 'returns the recruitment cycle data' do
        result = client.fetch_recruitment_cycle(2025)
        expect(result).to match(JSON.parse(body.read))
      end
    end

    context 'invalid recruitment cycle year' do
      let(:stub_body_path) { 'spec/examples/production_recruitment_cycle_timetables_api/fetch_recruitment_cycle_1999.json' }

      before do
        stub_request(:get, [described_class::BASE_URL, 2025].join('/'))
          .to_return(
            status: 404,
            body: body.read,
            headers: { 'Content-Type' => 'application/json' },
          )
      end

      it 'returns error' do
        result = client.fetch_recruitment_cycle(2025)
        expect(result).to match(JSON.parse(body.read))
      end
    end
  end

  describe '#fetch_all_recruitment_cycles' do
    let(:stub_body_path) { 'spec/examples/production_recruitment_cycle_timetables_api/fetch_all_recruitment_cycles.json' }

    before do
      stub_request(:get, described_class::BASE_URL)
        .to_return(
          status: 200,
          body: body.read,
          headers: { 'Content-Type' => 'application/json' },
        )
    end

    it 'returns all recruitment cycle timetables' do
      result = client.fetch_all_recruitment_cycles
      expect(result).to match(JSON.parse(body.read))
    end
  end
end
