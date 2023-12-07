require 'rails_helper'

RSpec.describe Chasers::Candidate do
  describe '.chaser_to_date_range' do
    it 'returns a chaser_type with respective date range' do
      expected = { offer_10_day: (20.days.ago..10.days.ago) }
      expect(described_class.chaser_to_date_range).to include(expected)
    end

    context 'when a block is passed' do
      it 'yields the chaser_type, start and end' do
        expected = [
          [:offer_10_day, 20.days.ago, 10.days.ago],
          [:offer_20_day, 30.days.ago, 20.days.ago],
          [:offer_30_day, 40.days.ago, 30.days.ago],
          [:offer_40_day, 50.days.ago, 40.days.ago],
          [:offer_50_day, 60.days.ago, 50.days.ago],
        ]
        expect { |b| described_class.chaser_to_date_range(&b) }.to yield_successive_args(*expected)
      end
    end
  end
end
