require 'rails_helper'

RSpec.describe InspectInternationalGcseGrade do
  let(:country_code) { 'NG' }
  let(:qualification_subject) { 'maths' }
  let(:grade) { 'A1' }

  let(:qualification) do
    build(
      :application_qualification,
      level: 'gcse',
      grade:,
      subject: qualification_subject,
      non_uk_qualification_type: 'WASSCE (West African Senior School Certificate Examination)',
      institution_country: country_code,
    )
  end

  let(:finder) do
    InternationalQualifications::StructuredGcseOptionFinder.new(country_code, subject)
  end

  let(:equivalent_qualification) do
    finder.equivalent_qualifications.find do |qual|
      qual.name == qualification.non_uk_qualification_type
    end
  end

  let(:schema) do
    finder.grade_schemas(equivalent_qualification).first
  end

  describe '#likely_below?' do
    context 'when structured grade data is unavailable' do
      let(:grade) { 'E' }

      before do
        qualification.update(non_uk_qualification_type: 'Unknown qualification')
      end

      it 'returns false' do
        expect(described_class.new(qualification).likely_below?).to be(false)
      end
    end

    context 'when the grade is not in the schema' do
      let(:grade) { 'Z' }

      it 'returns false' do
        expect(described_class.new(qualification).likely_below?).to be(false)
      end
    end

    context 'when the grade is a passing grade' do
      let(:grade) { 'A2' }

      it 'returns false' do
        expect(described_class.new(qualification).likely_below?).to be(false)
      end
    end

    context 'when the grade is a likely below grade' do
      let(:grade) { 'D7' }

      it 'returns true' do
        expect(described_class.new(qualification).likely_below?).to be(true)
      end
    end
  end

  describe '#structured_grade_data_available?' do
    context 'when an equivalent qualification exists' do
      it 'returns true' do
        expect(described_class.new(qualification).structured_grade_data_available?).to be(true)
      end
    end

    context 'when no equivalent qualification exists' do
      before do
        qualification.update(non_uk_qualification_type: 'Unknown qualification')
      end

      it 'returns false' do
        expect(described_class.new(qualification).structured_grade_data_available?).to be(false)
      end
    end

    describe '#requires_grade_schema_selection?' do
      context 'when multiple grade schemas are available' do
        let(:country_code) { 'IN' }
        let(:qualification_subject) { 'english' }

        before do
          qualification.update!(
            non_uk_qualification_type: 'CBSE Class 10 (AISSE)',
          )
        end

        it 'returns true' do
          expect(described_class.new(qualification).requires_grade_schema_selection?).to be(true)
        end
      end

      context 'when a percentage grade schema is available' do
        let(:country_code) { 'IN' }
        let(:qualification_subject) { 'english' }

        before do
          qualification.update!(
            non_uk_qualification_type: 'ICSE (Indian Certificate of Secondary Education)',
          )
        end

        it 'returns true' do
          expect(described_class.new(qualification).requires_grade_schema_selection?).to be(true)
        end
      end
    end
  end
end
