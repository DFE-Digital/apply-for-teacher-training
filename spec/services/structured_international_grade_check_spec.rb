require 'rails_helper'

RSpec.describe StructuredInternationalGradeCheck do
  let(:country_code) { 'NG' }

  let(:qualification) do
    double(
      grade:,
      non_uk_qualification_type: 'WASSCE (West African Secondary School Certificate Examination)',
      institution_country: country_code,
    )
  end

  let(:finder) do
    instance_double(InternationalQualifications::StructuredGcseOptionFinder)
  end

  let(:equivalent_qualification) do
    double(name: 'WASSCE (West African Secondary School Certificate Examination)')
  end

  let(:schema) do
    double(
      passing_grades: %w[A A− B+ B B− C+ C C−],
      failing_grades: %w[D+ D D− E],
    )
  end

  before do
    allow(InternationalQualifications::StructuredGcseOptionFinder)
      .to receive(:new)
      .with(qualification.institution_country)
      .and_return(finder)

    allow(finder)
      .to receive(:equivalent_qualifications)
      .and_return([equivalent_qualification])

    allow(finder)
      .to receive(:grade_schemas)
      .with(equivalent_qualification)
      .and_return([schema])
  end

  describe '#passing?' do
    context 'when structured grade data is unavailable' do
      let(:grade) { 'E' }

      before do
        allow(finder)
          .to receive(:equivalent_qualifications)
          .and_return([])
      end

      it 'returns true' do
        expect(described_class.new(qualification).passing?).to be(true)
      end
    end

    context 'when the grade is not in the schema' do
      let(:grade) { 'Z' }

      it 'returns true' do
        expect(described_class.new(qualification).passing?).to be(true)
      end
    end

    context 'when the grade is a passing grade' do
      let(:grade) { 'B+' }

      it 'returns true' do
        expect(described_class.new(qualification).passing?).to be(true)
      end
    end

    context 'when the grade is a failing grade' do
      let(:grade) { 'D+' }

      it 'returns false' do
        expect(described_class.new(qualification).passing?).to be(false)
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
        allow(finder)
          .to receive(:equivalent_qualifications)
          .and_return([])
      end

      it 'returns false' do
        expect(described_class.new(qualification).structured_grade_data_available?).to be(false)
      end
    end
  end
end
