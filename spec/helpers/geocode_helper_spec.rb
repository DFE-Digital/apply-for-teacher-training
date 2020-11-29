require 'rails_helper'

RSpec.describe GeocodeHelper, type: :helper do
  describe '#format_average_distance' do
    it 'returns a rounded string with units given a valid average' do
      service = instance_double(CandidateInterface::MeasureDistances)
      allow(CandidateInterface::MeasureDistances).to receive(:new).and_return(service)
      allow(service).to receive(:average_distance).with(:start, :destinations).and_return(12.34567)

      expect(helper.format_average_distance(:start, :destinations)).to eq('12.3 miles')
    end

    it 'returns a rounded string without units given a valid average' do
      service = instance_double(CandidateInterface::MeasureDistances)
      allow(CandidateInterface::MeasureDistances).to receive(:new).and_return(service)
      allow(service).to receive(:average_distance).with(:start, :destinations).and_return(12.34567)

      expect(helper.format_average_distance(:start, :destinations, with_units: false)).to eq('12.3')
    end

    it 'returns "n/a" when no average is available' do
      service = instance_double(CandidateInterface::MeasureDistances)
      allow(CandidateInterface::MeasureDistances).to receive(:new).and_return(service)
      allow(service).to receive(:average_distance).with(:start, :destinations).and_return(nil)

      expect(helper.format_average_distance(:start, :destinations)).to eq('n/a')
    end
  end

  describe '#format_distance' do
    it 'returns a rounded string with units given a valid average' do
      service = instance_double(CandidateInterface::MeasureDistances)
      allow(CandidateInterface::MeasureDistances).to receive(:new).and_return(service)
      allow(service).to receive(:distance).with(:start, :destinations).and_return(12.34567)

      expect(helper.format_distance(:start, :destinations)).to eq('12.3 miles')
    end

    it 'returns a rounded string without units given a valid average' do
      service = instance_double(CandidateInterface::MeasureDistances)
      allow(CandidateInterface::MeasureDistances).to receive(:new).and_return(service)
      allow(service).to receive(:distance).with(:start, :destinations).and_return(12.34567)

      expect(helper.format_distance(:start, :destinations, with_units: false)).to eq('12.3')
    end

    it 'returns "n/a" when no average is available' do
      service = instance_double(CandidateInterface::MeasureDistances)
      allow(CandidateInterface::MeasureDistances).to receive(:new).and_return(service)
      allow(service).to receive(:distance).with(:start, :destinations).and_return(nil)

      expect(helper.format_distance(:start, :destinations)).to eq('n/a')
    end

    it 'returns "" when no average is available without units' do
      service = instance_double(CandidateInterface::MeasureDistances)
      allow(CandidateInterface::MeasureDistances).to receive(:new).and_return(service)
      allow(service).to receive(:distance).with(:start, :destinations).and_return(nil)

      expect(helper.format_distance(:start, :destinations, with_units: false)).to eq('')
    end
  end
end
