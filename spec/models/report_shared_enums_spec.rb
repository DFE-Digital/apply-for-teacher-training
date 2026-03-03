require 'rails_helper'

RSpec.describe ReportSharedEnums do
  describe '.england_regions' do
    it 'returns england regions' do
      expect(described_class.england_regions).to eq(
        {
          west_midlands: 'West Midlands (England)',
          north_west: 'North West (England)',
          london: 'London',
          north_east: 'North East (England)',
          south_west: 'South West (England)',
          east_midlands: 'East Midlands (England)',
          east_of_england: 'East (England)',
          yorkshire_and_the_humber: 'Yorkshire and The Humber',
          south_east: 'South East (England)',
        },
      )
    end
  end

  describe '.england_regions_including_england' do
    it 'returns england regions including england' do
      expect(described_class.england_regions_including_england).to eq(
        {
          all_of_england: 'All of England',
          west_midlands: 'West Midlands (England)',
          north_west: 'North West (England)',
          london: 'London',
          north_east: 'North East (England)',
          south_west: 'South West (England)',
          east_midlands: 'East Midlands (England)',
          east_of_england: 'East of England',
          yorkshire_and_the_humber: 'Yorkshire and The Humber',
          south_east: 'South East (England)',
        },
      )
    end
  end

  describe '.all_of_england_key' do
    it 'returns all_of_england key' do
      expect(described_class.all_of_england_key).to eq('all_of_england')
    end
  end

  describe '.all_of_england_value' do
    it 'returns all_of_england value' do
      expect(described_class.all_of_england_value).to eq('All of England')
    end
  end

  describe '.edi_categories' do
    it 'returns edi categories' do
      expect(described_class.edi_categories).to eq(
        {
          ethnic_group: 'Ethnic group',
          sex: 'Sex',
          age_group: 'Age group',
          disability: 'Disability',
        },
      )
    end
  end
end
