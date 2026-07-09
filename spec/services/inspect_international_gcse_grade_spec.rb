require 'rails_helper'

RSpec.describe InspectInternationalGcseGrade do
  let(:country_code) { 'NG' }

  let(:qualification) do
    build(
      :application_qualification,
      level: 'gcse',
      grade:,
      non_uk_qualification_type: 'WASSCE (West African Senior School Certificate Examination)',
      institution_country: country_code,
    )
  end

  let(:finder) do
    InternationalQualifications::StructuredGcseOptionFinder.new(country_code)
  end

  let(:equivalent_qualification) do
    finder.equivalent_qualifications.find do |qual|
      qual.name == qualification.non_uk_qualification_type
    end
  end

  let(:schema) do
    finder.grade_schemas(equivalent_qualification).first
  end

  describe '#failing' do
    context 'when structured grade data is unavailable' do
      let(:grade) { 'E' }

      before do
        qualification.update(non_uk_qualification_type: 'Unknown qualification')
      end

      it 'returns false' do
        expect(described_class.new(qualification).failing?).to be(false)
      end
    end

    context 'when the grade is not in the schema' do
      let(:grade) { 'Z' }

      it 'returns false' do
        expect(described_class.new(qualification).failing?).to be(false)
      end
    end

    context 'when the grade is a passing grade' do
      let(:grade) { 'A2' }

      it 'returns false' do
        expect(described_class.new(qualification).failing?).to be(false)
      end
    end

    context 'when the grade is a failing grade' do
      let(:grade) { 'D7' }

      it 'returns true' do
        expect(described_class.new(qualification).failing?).to be(true)
      end
    end
  end

  describe '#structured_grade_data_available?' do
    context 'when an equivalent qualification exists' do
      let(:grade) { 'A' }

      it 'returns true' do
        expect(described_class.new(qualification).structured_grade_data_available?).to be(true)
      end
    end

    context 'when no equivalent qualification exists' do
      let(:grade) { 'A' }

      before do
        qualification.update(non_uk_qualification_type: 'Unknown qualification')
      end

      it 'returns false' do
        expect(described_class.new(qualification).structured_grade_data_available?).to be(false)
      end
    end
  end
end
