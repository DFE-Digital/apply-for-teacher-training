require 'rails_helper'

RSpec.describe Publications::CompareMinisterialReports do
  let(:tad_data) do
    {
      english: {
        candidates: [7, 8, 9],
        offers_received: [7],
        accepted: [],
        rejected: [10],
      },
      mathematics: {
        candidates: [1, 2, 3],
        offers_received: [2, 3],
        accepted: [3],
        rejected: [5, 6],
      },
      chemistry: {
        candidates: [11, 12, 13],
        offers_received: [12],
        accepted: [12],
        rejected: [14, 15],
      },
    }
  end
  let(:bat_data) do
    {
      english: {
        candidates: [7, 8, 9],
        offers_received: [7],
        accepted: [],
        rejected: [],
      },
      mathematics: {
        candidates: [1, 2, 3, 4, 5],
        offers_received: [2, 3, 4],
        accepted: [3, 4],
        rejected: [5],
      },
      chemistry: {
        candidates: [11, 12, 13],
        offers_received: [12],
        accepted: [12],
        rejected: [14, 15],
      },
    }
  end
  let(:expected_diff) {
    {
      english: {
        candidates: { only_tad: nil, only_bat: nil, tad_total: 3, bat_total: 3 },
        offers_received: { only_tad: nil, only_bat: nil, tad_total: 1, bat_total: 1 },
        accepted: { only_tad: nil, only_bat: nil, tad_total: 0, bat_total: 0 },
        rejected: { only_tad: [10], only_bat: nil, tad_total: 1, bat_total: 0 },
      },
      mathematics: {
        candidates: { only_tad: nil, only_bat: [4, 5], tad_total: 3, bat_total: 5 },
        offers_received: { only_tad: nil, only_bat: [4], tad_total: 2, bat_total: 3 },
        accepted: { only_tad: nil, only_bat: [4], tad_total: 1, bat_total: 2 },
        rejected: { only_tad: [6], only_bat: nil, tad_total: 2, bat_total: 1 },
      },
      chemistry: nil,
    }
  }

  subject(:service) { described_class.new(bat_data: bat_data, tad_data: tad_data) }

  it 'returns the correct results' do
    expect(service.diff).to eq(expected_diff)
  end
end
