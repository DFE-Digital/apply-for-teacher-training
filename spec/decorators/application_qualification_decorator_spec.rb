require 'rails_helper'
RSpec.describe ApplicationQualificationDecorator do
  describe '#grade_details' do
    describe 'rendering multiple English GCSEs' do
      let(:application_qualification) do
        create(:gcse_qualification, grade: nil, subject: 'english', constituent_grades: { english_language: { grade: 'E' }, english_literature: { grade: 'E' }, 'Cockney Rhyming Slang': { grade: 'A*' } }, award_year: 2006)
      end

      it 'renders grades for multiple English GCSEs' do
        grade_details = described_class.new(application_qualification).grade_details

        expect(grade_details['english_language']).to eq('E (English language)')
        expect(grade_details['english_literature']).to eq('E (English literature)')
        expect(grade_details['Cockney Rhyming Slang']).to eq('A* (Cockney rhyming slang)')
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

        expect(grade_details['biology']).to eq('A (Biology)')
        expect(grade_details['chemistry']).to eq('B (Chemistry)')
        expect(grade_details['physics']).to eq('C (Physics)')
      end

      context 'when the constituent grades are not present' do
        let(:science_triple_awards) { nil }

        it 'renders "grade information not available" for each subject' do
          grade_details = described_class.new(application_qualification).grade_details

          expect(grade_details['biology']).to include('Grade information not available (biology)')
          expect(grade_details['chemistry']).to include('Grade information not available (chemistry)')
          expect(grade_details['physics']).to include('Grade information not available (physics)')
        end
      end

      context 'when the qualification is marked as missing' do
        let(:qualification_type) { 'missing' }

        it 'renders nothing for the grade details' do
          grade_details = described_class.new(application_qualification).grade_details

          expect(grade_details).to eq({})
        end
      end
    end

    describe '#formatted_degree_and_grade' do
      context 'when it is a completed honours degree' do
        let(:degree) {
          build(
            :degree_qualification,
            qualification_type: 'Bachelor of Science',
            subject: 'Mathematics',
            predicted_grade: false,
            grade: 'First-class honours',
          )
        }

        it 'returns abbreviated degree with (Hons) and short grade' do
          expect(described_class.new(degree).formatted_degree_and_grade).to eq('BSc (Hons) Mathematics, First')
        end
      end

      context 'when it is a completed degree without honours' do
        let(:degree) {
          build(
            :degree_qualification,
            qualification_type: 'Bachelor of Arts',
            subject: 'English literature',
            predicted_grade: false,
            grade: 'Third-class',
          )
        }

        it 'returns abbreviated degree without (Hons) and full grade text' do
          expect(described_class.new(degree).formatted_degree_and_grade).to eq('BA English Literature, Third-class')
        end
      end

      context 'when it is an international degree or other unstructured type' do
        let(:degree) {
          build(
            :non_uk_degree_qualification,
            qualification_type: 'Bachelor',
            subject: 'Modern Languages',
            predicted_grade: false,
            grade: '89',
          )
        }

        it 'returns unstructured free text degree and grade' do
          expect(described_class.new(degree).formatted_degree_and_grade).to eq('Bachelor Modern Languages, 89')
        end
      end

      context 'when it is a predicted degree' do
        let(:degree) {
          build(
            :degree_qualification,
            qualification_type: 'Bachelor of Engineering',
            subject: 'Civil Engineering',
            predicted_grade: true,
            grade: 'Lower second-class honours (2:2)',
          )
        }

        it 'includes the (predicted) label in grade' do
          expect(described_class.new(degree).formatted_degree_and_grade).to eq('BEng (Hons) Civil Engineering, 2:2 (predicted)')
        end
      end

      context 'when the grade is missing' do
        let(:degree) {
          build(
            :degree_qualification,
            qualification_type: 'Bachelor of Music',
            subject: 'Music Composition',
            predicted_grade: false,
            grade: nil,
          )
        }

        it 'returns only the degree type and subject' do
          expect(described_class.new(degree).formatted_degree_and_grade).to eq('BMus Music Composition')
        end
      end

      context 'when the qualification is not a degree' do
        let(:non_degree) {
          build(
            :gcse_qualification,
            qualification_type: 'gcse',
            subject: 'maths',
            grade: 'A',
          )
        }

        it 'returns nil' do
          expect(described_class.new(non_degree).formatted_degree_and_grade).to be_nil
        end
      end
    end
  end
end
