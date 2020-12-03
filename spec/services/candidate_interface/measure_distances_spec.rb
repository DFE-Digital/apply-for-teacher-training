require 'rails_helper'

RSpec.describe CandidateInterface::MeasureDistances do
  describe '#distance' do
    it 'returns correct distance between geocoded destinations' do
      start = build(:application_form, latitude: 51.5973506, longitude: -1.2967454)
      destination = build(:site, latitude: 51.6097184, longitude: -1.2482939)
      expect(described_class.new.distance(start, destination)).to be_within(0.1).of(2.2)
    end

    it 'handles nil lat/lng values for `start` model' do
      start = build(:application_form, latitude: nil, longitude: nil)
      destination = build(:site, latitude: 51.6097184, longitude: -1.2482939)
      expect(described_class.new.distance(start, destination)).to be_nil
    end

    it 'handles nil lat/lng values for `destination` model' do
      start = build(:application_form, latitude: 51.5973506, longitude: -1.2967454)
      destination = build(:site, latitude: nil, longitude: nil)
      expect(described_class.new.distance(start, destination)).to be_nil
    end

    it 'handles nil `destination` model' do
      start = build(:application_form, latitude: 51.5973506, longitude: -1.2967454)
      expect(described_class.new.distance(start, nil)).to be_nil
    end
  end

  describe '#average_distance' do
    it 'returns correct average given multiple destinations' do
      start = build(:application_form, latitude: 51.5973506, longitude: -1.2967454)
      destinations = [
        build(:site, latitude: 51.6097184, longitude: -1.2482939),
        build(:site, latitude: 51.6072222, longitude: -1.2407998),
        build(:site, latitude: 51.605683, longitude: -1.2252001),
      ]
      expect(described_class.new.average_distance(start, destinations)).to be_within(0.1).of(2.6)
    end

    it 'handles nil lat/lng values for `start` model' do
      start = build(:application_form, latitude: nil, longitude: nil)
      destinations = [
        build(:site, latitude: 51.6097184, longitude: -1.2482939),
      ]
      expect(described_class.new.average_distance(start, destinations)).to be_nil
    end

    it 'handles nil lat/lng values for all of the `destinations`' do
      start = build(:application_form, latitude: 51.5973506, longitude: -1.2967454)
      destinations = [
        build(:site, latitude: nil, longitude: nil),
        build(:site, latitude: nil, longitude: nil),
      ]
      expect(described_class.new.average_distance(start, destinations)).to be_nil
    end

    it 'handles nil lat/lng values for some of the `destinations`' do
      start = build(:application_form, latitude: 51.5973506, longitude: -1.2967454)
      destinations = [
        build(:site, latitude: nil, longitude: nil),
        build(:site, latitude: 51.6072222, longitude: -1.2407998),
        build(:site, latitude: 51.605683, longitude: -1.2252001),
      ]
      expect(described_class.new.average_distance(start, destinations)).to be_within(0.1).of(2.8)
    end
  end
end
