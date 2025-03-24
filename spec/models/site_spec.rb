require 'rails_helper'

RSpec.describe Site do
  subject { create(:site) }

  let(:current_year) { RecruitmentCycleTimetable.current_year }
  let(:previous_year) { RecruitmentCycleTimetable.previous_year }

  describe 'a valid site' do
    it { is_expected.to validate_presence_of :code }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :uuid }
  end

  describe '.for_recruitment_cycle_years' do
    it 'returns sites for the specific recruitment cycle year' do
      site_current_cycle = create(:course_option).site
      create(:course_option, :previous_year).site

      expect(described_class.for_recruitment_cycle_years([current_year])).to contain_exactly(site_current_cycle)
    end

    it 'returns sites for multiple recruitment cycle years' do
      site_current_cycle = create(:course_option).site
      site_previous_cycle = create(:course_option, :previous_year).site

      expect(described_class.for_recruitment_cycle_years([current_year, previous_year])).to contain_exactly(
        site_current_cycle,
        site_previous_cycle,
      )
    end

    it 'returns distinct sites for a specific recruitment cycle year' do
      course_option = create(:course_option, :full_time)
      create(:course_option, :part_time, site: course_option.site, course: course_option.course)

      expect(described_class.for_recruitment_cycle_years([current_year]).count).to eq(1)
    end

    it 'does not return sites if none exist for that year' do
      expect(described_class.for_recruitment_cycle_years([current_year])).to be_empty
    end

    it 'does not return orphaned sites for a provider' do
      site = create(:site)

      expect(site.provider.sites.for_recruitment_cycle_years([current_year])).to be_empty
    end
  end

  describe '.uniq_by_location' do
    let(:longitude1) { Faker::Address.longitude.round(4) }
    let(:longitude2) { Faker::Address.longitude.round(4) }
    let(:latitude1) { Faker::Address.latitude.round(4) }
    let(:latitude2) { Faker::Address.latitude.round(4) }

    before do
      create(:site, latitude: latitude1, longitude: longitude1)
      create(:site, latitude: latitude1, longitude: longitude1)
      create(:site, latitude: latitude2, longitude: longitude2)
    end

    it 'returns distinct sites for a given latitude and longitude' do
      locations = described_class.uniq_by_location.pluck(:longitude, :latitude)
      expect(locations).to contain_exactly([longitude1, latitude1], [longitude2, latitude2])
    end
  end

  describe '#full_address' do
    let(:site) do
      build(
        :site,
        address_line1: 'Gorse SCITT',
        address_line2: 'C/O The Bruntcliffe Academy',
        address_line3: 'Bruntcliffe Lane',
        address_line4: 'MORLEY, LEEDS',
        postcode: 'LS27 0LZ',
      )
    end

    it 'concatenates the address lines and postcode' do
      expect(site.full_address).to eq('Gorse SCITT, C/O The Bruntcliffe Academy, Bruntcliffe Lane, MORLEY, LEEDS, LS27 0LZ')
    end

    it 'ignores empty address lines when concatenating' do
      site = build(
        :site,
        address_line1: '',
        address_line2: 'C/O The Bruntcliffe Academy',
        address_line3: '',
        address_line4: 'MORLEY, LEEDS',
        postcode: 'LS27 0LZ',
      )

      expect(site.full_address).to eq('C/O The Bruntcliffe Academy, MORLEY, LEEDS, LS27 0LZ')
    end

    it 'concatenates by new lines if passed in' do
      expect(site.full_address("\n")).to eq("Gorse SCITT\nC/O The Bruntcliffe Academy\nBruntcliffe Lane\nMORLEY, LEEDS\nLS27 0LZ")
    end
  end

  describe 'geocoded?' do
    it 'returns true when latitude/longitude are specified' do
      site = build(
        :site,
        latitude: '51.498024',
        longitude: '0.129919',
      )
      expect(site.geocoded?).to be true
    end

    it 'returns false when latitude is nil' do
      site = build(
        :site,
        latitude: nil,
        longitude: '0.129919',
      )
      expect(site.geocoded?).to be false
    end
  end
end
