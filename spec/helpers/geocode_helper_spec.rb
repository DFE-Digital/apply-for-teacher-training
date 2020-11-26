require 'rails_helper'

RSpec.describe GeocodeHelper, type: :helper do
  describe '#format_average_distance' do
    it 'returns a rounded string with units given a valid average' do
      service = instance_double(CandidateInterface::MeasureDistances)
      allow(CandidateInterface::MeasureDistances).to receive(:new).and_return(service)
      allow(service).to receive(:average_distance).with(:start, :destinations).and_return(12.34567)

      expect(helper.format_average_distance(:start, :destinations)).to eq('12.3 miles')
    end

    it 'returns "n/a" when no average is available' do
      service = instance_double(CandidateInterface::MeasureDistances)
      allow(CandidateInterface::MeasureDistances).to receive(:new).and_return(service)
      allow(service).to receive(:average_distance).with(:start, :destinations).and_return(nil)

      expect(helper.format_average_distance(:start, :destinations)).to eq('n/a')
    end
  end
end
