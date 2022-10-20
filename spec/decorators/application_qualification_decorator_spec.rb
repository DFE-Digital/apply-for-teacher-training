require 'rails_helper'
RSpec.describe ApplicationQualificationDecorator do
  describe '#grade_details' do
    describe 'rendering multiple English GCSEs' do
      let(:application_qualification) do
        create(:gcse_qualification, subject: 'english', constituent_grades: { english_language: { grade: 'E' }, english_literature: { grade: 'E' }, 'Cockney Rhyming Slang': { grade: 'A*' } }, award_year: 2006)
      end

      it 'renders grades for multiple English GCSEs' do
        grade_details = described_class.new(application_qualification).grade_details

        expect(grade_details).to include('E (English language)')
        expect(grade_details).to include('E (English literature)')
        expect(grade_details).to include('A* (cockney rhyming slang)')
      end
    end

    describe 'rendering multiple Science GCSEs' do
      let(:science_triple_awards) do
        {
          biology: { grade: 'A' },
          chemistry: { grade: 'B' },
          physics: { grade: 'C' },
        }
      end

      let(:qualification_type) { 'gcse' }

      let(:application_qualification) do
        create(
          :gcse_qualification,
          award_year: 2006,
          constituent_grades: science_triple_awards,
          qualification_type:,
          subject: 'science triple award',
        )
      end

      it 'renders grades for multiple Science GCSEs' do
        grade_details = described_class.new(application_qualification).grade_details

        expect(grade_details).to include('A (biology)')
        expect(grade_details).to include('B (chemistry)')
        expect(grade_details).to include('C (physics)')
      end

      context 'when the constituent grades are not present' do
        let(:science_triple_awards) { nil }

        it 'renders "grade information not available" for each subject' do
          grade_details = described_class.new(application_qualification).grade_details

          expect(grade_details).to include('Grade information not available (biology)')
          expect(grade_details).to include('Grade information not available (chemistry)')
          expect(grade_details).to include('Grade information not available (physics)')
        end
      end

      context 'when the qualification is marked as missing' do
        let(:qualification_type) { 'missing' }

        it 'renders nothing for the grade details' do
          grade_details = described_class.new(application_qualification).grade_details

          expect(grade_details).to eq([])
        end
      end
    end
  end
end
