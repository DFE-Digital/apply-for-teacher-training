require 'rails_helper'

RSpec.describe HesaQualificationFieldsPresenter do
  describe '#to_hash' do
    let(:qualification) { create(:degree_qualification) }
    let(:presenter) { described_class.new(qualification) }

    direct_mappings = {
      hesa_degtype: { attr: :qualification_type_hesa_code, zeropad: 3 },
      hesa_degsbj: { attr: :subject_hesa_code, zeropad: 6 },
      hesa_degclss: { attr: :grade_hesa_code, zeropad: 2 },
      hesa_degest: { attr: :institution_hesa_code, zeropad: 4 },
    }

    direct_mappings.each do |hesa_field, data|
      our_field = data[:attr]
      pad_to = data[:zeropad]

      it "#{hesa_field} is #{our_field} zero-padded to #{pad_to} chars" do
        expect(presenter.to_hash[hesa_field]).to eq(qualification.send(our_field)&.to_s&.rjust(pad_to, '0'))
      end
    end

    context 'when iso3166 institution country code differs from HESA degctry code' do
      described_class::HESA_DEGCTRY_MAPPING.each do |iso3166_code, hesa_degctry_code|
        it "maps #{iso3166_code} to #{hesa_degctry_code}" do
          presenter = described_class.new(build(:degree_qualification, institution_country: iso3166_code))
          expect(presenter.to_hash[:hesa_degctry]).to eq(hesa_degctry_code)
        end
      end
    end

    context 'when iso3166 institution country code matches HESA degctry code' do
      it 'returns the institution country code' do
        iso3166_code = COUNTRIES.except(described_class::HESA_DEGCTRY_MAPPING.keys).keys.sample
        presenter = described_class.new(build(:degree_qualification, institution_country: iso3166_code))
        expect(presenter.to_hash[:hesa_degctry]).to eq(iso3166_code)
      end
    end

    it 'hesa_degstdt is start_year in ISO8601 format' do
      expect(presenter.to_hash[:hesa_degstdt]).to eq("#{qualification.start_year}-01-01")
    end

    it 'hesa_degenddt is award_year in ISO8601 format' do
      expect(presenter.to_hash[:hesa_degenddt]).to eq("#{qualification.award_year}-01-01")
    end

    it 'returns nil values for non-degree qualifications' do
      non_degree = create(:gcse_qualification)
      presenter = described_class.new(non_degree)
      expected = {
        hesa_degtype: nil,
        hesa_degsbj: nil,
        hesa_degclss: nil,
        hesa_degest: nil,
        hesa_degctry: nil,
        hesa_degstdt: nil,
        hesa_degenddt: nil,
      }
      expect(presenter.to_hash).to eq(expected)
    end
  end
end
