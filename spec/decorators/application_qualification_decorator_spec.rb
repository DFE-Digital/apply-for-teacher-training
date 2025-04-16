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

    describe '#degree_type_and_subject' do
      context 'when it is a completed honours degree' do
        let(:application_form) {
          create(:application_form, :completed, application_qualifications: [
            build(:degree_qualification,
                  qualification_type: 'Bachelor of Science',
                  subject: 'Mathematics',
                  predicted_grade: false,
                  grade: 'First-class honours'),
          ])
        }
        let(:decorated_degree) { described_class.new(application_form.last_degree) }
        let(:abbreviated_degree) { decorated_degree.degree_type_and_subject(application_form.last_degree) }

        it 'renders the abbreviated degree with (hons)' do
          expect(abbreviated_degree).to include('BSc (Hons) Mathematics')
        end
      end

      context 'when it is a completed degree without honours' do
        let(:application_form) {
          create(:application_form, :completed, application_qualifications: [
            build(:degree_qualification,
                  qualification_type: 'Bachelor of Arts',
                  subject: 'English Literature',
                  predicted_grade: false,
                  grade: 'Third-class'),
          ])
        }
        let(:decorated_degree) { described_class.new(application_form.last_degree) }
        let(:abbreviated_degree) { decorated_degree.degree_type_and_subject(application_form.last_degree) }

        it 'renders the abbreviated degree without (hons)' do
          expect(abbreviated_degree).to include('BA English Literature')
        end
      end

      context 'when it is an international degree or another qualification type' do
        let(:application_form) {
          create(:application_form, :completed, application_qualifications: [
            build(:non_uk_degree_qualification,
                  qualification_type: 'Bachelor',
                  subject: 'Modern Languages',
                  predicted_grade: false,
                  grade: '89'),
          ])
        }
        let(:decorated_degree) { described_class.new(application_form.last_degree) }
        let(:abbreviated_degree) { decorated_degree.degree_type_and_subject(application_form.last_degree) }

        it 'renders the unstructured free text' do
          expect(abbreviated_degree).to include('Bachelor Modern Languages')
        end
      end
    end

    describe '#formatted_grade' do
      context 'when it is a completed degree with a grade' do
        let(:application_form) {
          create(:application_form, :completed, application_qualifications: [
            build(:degree_qualification,
                  qualification_type: 'Bachelor of Education',
                  subject: 'European History',
                  predicted_grade: false,
                  grade: 'Third-class honours'),
          ])
        }
        let(:decorated_degree) { described_class.new(application_form.last_degree) }
        let(:formatted_grade) { decorated_degree.formatted_grade(application_form.last_degree) }

        it 'renders the short form grade' do
          expect(formatted_grade).to include('3rd')
        end
      end

      context 'when it is a incomplete degree with a predicted grade' do
        let(:application_form) {
          create(:application_form, :completed, application_qualifications: [
            build(:degree_qualification,
                  qualification_type: 'Bachelor of Engineering',
                  subject: 'Civil Engineering',
                  predicted_grade: true,
                  grade: 'Lower second-class honours (2:2)'),
          ])
        }
        let(:decorated_degree) { described_class.new(application_form.last_degree) }
        let(:formatted_grade) { decorated_degree.formatted_grade(application_form.last_degree) }

        it 'renders the short form grade' do
          expect(formatted_grade).to include('2:2 (predicted)')
        end
      end

      context 'when it is an international degree or another grade type' do
        let(:application_form) {
          create(:application_form, :completed, application_qualifications: [
            build(:non_uk_degree_qualification,
                  qualification_type: 'Bachelor',
                  subject: 'Modern Languages',
                  predicted_grade: false,
                  grade: '89'),
          ])
        }
        let(:decorated_degree) { described_class.new(application_form.last_degree) }
        let(:formatted_grade) { decorated_degree.formatted_grade(application_form.last_degree) }

        it 'renders the unstructured free text' do
          expect(formatted_grade).to include('89')
        end
      end
    end
  end
end
