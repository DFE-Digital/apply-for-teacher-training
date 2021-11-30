require 'rails_helper'
RSpec.describe ApplicationQualificationDecorator do
  describe '#grade_details' do
    describe 'rendering multiple English GCSEs' do
      let(:application_qualification) do
        create(:gcse_qualification, subject: 'english', constituent_grades: { english_language: { grade: 'E' }, english_literature: { grade: 'E' }, 'Cockney Rhyming Slang': { grade: 'A*' } }, award_year: 2006)
      end

      it 'renders grades for multiple English GCSEs' do
        grade_details = described_class.new(application_qualification).grade_details

        expect(grade_details).to include 'E (English Language)'
        expect(grade_details).to include 'E (English Literature)'
        expect(grade_details).to include 'A* (Cockney Rhyming Slang)'
      end
    end

    describe 'rendering multiple Science GCSEs' do
      science_triple_awards = {
        biology: { grade: 'A' },
        chemistry: { grade: 'B' },
        physics: { grade: 'C' },
      }

      let(:application_qualification) do
        create(:gcse_qualification,
               subject: 'science triple award',
               constituent_grades: science_triple_awards,
               award_year: 2006)
      end

      it 'renders grades for multiple English GCSEs' do
        grade_details = described_class.new(application_qualification).grade_details

        expect(grade_details).to include 'A (Biology)'
        expect(grade_details).to include 'B (Chemistry)'
        expect(grade_details).to include 'C (Physics)'
      end
    end
  end
end
