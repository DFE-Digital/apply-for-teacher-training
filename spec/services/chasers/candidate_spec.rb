require 'rails_helper'

RSpec.describe Chasers::Candidate do
  describe '.chaser_to_date_range' do
    it 'returns a chaser_type with respective date range' do
      expected = { offer_10_day: 10.days.ago.all_day }
      expect(described_class.chaser_to_date_range).to include(expected)
    end
  end
end
