require 'rails_helper'

RSpec.describe DomicileResolver do
  def hesa_code_for_country(iso_country_code)
    DomicileResolver.hesa_code_for_country iso_country_code
  end

  def hesa_code_for_postcode(uk_postcode)
    DomicileResolver.hesa_code_for_postcode uk_postcode
  end

  it 'returns ZZ if it receives a nil argument' do
    expect(hesa_code_for_country(nil)).to eq('ZZ')
    expect(hesa_code_for_postcode(nil)).to eq('ZZ')
  end

  describe 'for international addresses' do
    hesa_remaps = {
      'XX' => { country_code: 'AQ', country_name: 'Antarctica' },
      'XC' => { country_code: 'CY', country_name: 'Cyprus' },
      'QO' => { country_code: 'XK', country_name: 'Kosovo' },
    }

    hesa_remaps.each do |expected, iso|
      it "returns #{expected} when the country code is #{iso[:country_code]} (#{iso[:country_name]})" do
        expect(hesa_code_for_country(iso[:country_code])).to eq(expected)
      end
    end

    it 'returns the ISO code in all other cases' do
      expect(hesa_code_for_country('FR')).to eq('FR')
    end
  end

  describe 'for UK addresses' do
    it 'returns XF for English postcodes' do
      expect(hesa_code_for_postcode('SW1P 3BT')).to eq('XF')
    end

    it 'returns XI for Welsh postcodes' do
      expect(hesa_code_for_postcode('SA6 7JL')).to eq('XI')
    end

    it 'returns XH for Scottish postcodes' do
      expect(hesa_code_for_postcode('EH6 6QQ')).to eq('XH')
    end

    it 'returns XG for Northern Ireland' do
      expect(hesa_code_for_postcode('BT48 7NN')).to eq('XG')
    end

    it 'returns XL for Channel Islands' do
      expect(hesa_code_for_postcode('GY1 1FH')).to eq('XL')
    end

    it 'returns XK for non-geographical postcodes' do
      expect(hesa_code_for_postcode('BF1 2AA')).to eq('XK')
    end

    it 'returns XK for postcode prefixes spanning two countries' do
      expect(hesa_code_for_postcode('HR1 2LX')).to eq('XK')
    end
  end
end
