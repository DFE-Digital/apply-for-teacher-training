require 'rails_helper'

RSpec.describe InternationalQualifications::StructuredGcseOptionFinder do
  describe '.equivalent_qualifications' do
    context 'where country has an equivalent qualification' do
      %w[NG GH SL GM LR].each do |country_code|
        it "returns WASSCE for #{country_code}" do
          equivalent_qualifications = described_class.new(country_code, 'english').equivalent_qualifications
          expect(equivalent_qualifications.count).to eq 1
          equivalent_qualification = equivalent_qualifications.first
          expect(equivalent_qualification.name).to eq 'WASSCE (West African Senior School Certificate Examination)'
          expect(equivalent_qualification.countries).to eq(%w[NG GH SL GM LR])
        end

        it "attaches the relevant WASSCE grade schemes for #{country_code}" do
          equivalent_qualification = described_class.new(country_code, 'english').equivalent_qualifications.first

          expect(equivalent_qualification.grade_schemas.count).to eq 1
          grade_schema = equivalent_qualification.grade_schemas.first
          expect(grade_schema.likely_above_level_four).to eq(%w[A1 B2 B3 C4 C5 C6])
          expect(grade_schema.likely_below_level_four).to eq(%w[D7 E8 F9])
        end
      end

      %w[KE].each do |country_code|
        it "returns KCSE for #{country_code}" do
          equivalent_qualifications = described_class.new(country_code, 'english').equivalent_qualifications
          expect(equivalent_qualifications.count).to eq 1
          equivalent_qualification = equivalent_qualifications.first
          expect(equivalent_qualification.name).to eq 'KCSE (Kenya Certificate of Secondary Education)'
          expect(equivalent_qualification.countries).to eq(%w[KE])
        end

        it "attaches the relevant KCSE grade schemes for #{country_code}" do
          equivalent_qualification = described_class.new(country_code, 'english').equivalent_qualifications.first

          expect(equivalent_qualification.grade_schemas.count).to eq 1
          grade_schema = equivalent_qualification.grade_schemas.first
          expect(grade_schema.likely_above_level_four).to eq(%w[A A− B+ B B− C+ C C−])
          expect(grade_schema.likely_below_level_four).to eq(%w[D+ D D− E])
        end
      end
    end

    context 'when the country does not have an equivalent qualification' do
      let(:country_code) { 'DE' }

      it 'returns empty array' do
        equivalent_qualifications = described_class.new(country_code, 'english').equivalent_qualifications
        expect(equivalent_qualifications).to eq([])
      end
    end
  end
end
