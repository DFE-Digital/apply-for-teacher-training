require 'rails_helper'

RSpec.describe CandidateInterface::MeasureDistances do
  describe '#average_distance' do
    it 'returns correct average given multiple destinations' do
      start = instance_double(ApplicationForm, latitude: 51.5973506, longitude: -1.2967454)
      destinations = [
        instance_double(Site, latitude: 51.6097184, longitude: -1.2482939),
        instance_double(Site, latitude: 51.6072222, longitude: -1.2407998),
        instance_double(Site, latitude: 51.605683, longitude: -1.2252001),
      ]
      expect(described_class.new.average_distance(start, destinations)).to be_within(0.1).of(2.6)
    end

    it 'handles nil lat/lng values for `start` model' do
      start = instance_double(ApplicationForm, latitude: nil, longitude: nil)
      destinations = [
        instance_double(Site, latitude: 51.6097184, longitude: -1.2482939),
      ]
      expect(described_class.new.average_distance(start, destinations)).to be_nil
    end

    it 'handles nil lat/lng values for all of the `destinations`' do
      start = instance_double(ApplicationForm, latitude: 51.5973506, longitude: -1.2967454)
      destinations = [
        instance_double(Site, latitude: nil, longitude: nil),
        instance_double(Site, latitude: nil, longitude: nil),
      ]
      expect(described_class.new.average_distance(start, destinations)).to be_nil
    end

    it 'handles nil lat/lng values for some of the `destinations`' do
      start = instance_double(ApplicationForm, latitude: 51.5973506, longitude: -1.2967454)
      destinations = [
        instance_double(Site, latitude: nil, longitude: nil),
        instance_double(Site, latitude: 51.6072222, longitude: -1.2407998),
        instance_double(Site, latitude: 51.605683, longitude: -1.2252001),
      ]
      expect(described_class.new.average_distance(start, destinations)).to be_within(0.1).of(2.8)
    end
  end
end
