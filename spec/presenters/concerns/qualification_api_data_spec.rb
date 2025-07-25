require 'rails_helper'

RSpec.describe QualificationAPIData do
  include QualificationsPresenterHelper

  subject(:presenter) { QualificationClass.new(application_choice) }

  let(:qualification_class) do
    Class.new do
      include QualificationAPIData

      attr_accessor :application_choice, :application_form

      def initialize(application_choice)
        @application_choice = ApplicationChoiceExportDecorator.new(application_choice)
        @application_form = application_choice.application_form
      end
    end
  end

  before do
    stub_const('QualificationClass', qualification_class)
  end

  describe '#other_qualifications' do
    let(:application_choice) do
      create(:application_choice, :offered, application_form: create(:completed_application_form))
    end

    context 'id' do
      let!(:qualification) { create(:other_qualification, application_form: application_choice.application_form) }

      it 'uses the public_id of a qualification as the id' do
        expect(presenter.qualifications[:other_qualifications][0][:id]).to eq qualification.public_id
      end
    end

    context 'hesa fields' do
      before { create(:other_qualification, :non_uk, application_form: application_choice.application_form) }

      it 'contains HESA qualification fields' do
        expect(presenter.qualifications[:other_qualifications][0]).to have_key(:hesa_degstdt)
      end
    end

    context 'non_uk_qualification_type' do
      let!(:qualification) { create(:gcse_qualification, :non_uk, application_form: application_choice.application_form) }

      it 'includes a non_uk_qualification_type for non-UK qualifications' do
        expect(presenter.qualifications[:gcses].one? { |q| q[:non_uk_qualification_type] == qualification.non_uk_qualification_type }).to be true
      end
    end

    context 'missing grades' do
      let!(:qualification) { create(:gcse_qualification, grade: nil, application_form: application_choice.application_form) }

      it 'renders as "Not Entered"' do
        expect(presenter.qualifications[:gcses][0][:grade]).to eq('Not entered')
      end
    end

    describe 'subject_code' do
      context 'gcse level science qualifications' do
        let(:science_triple_awards) do
          {
            biology: { grade: 'A' },
            chemistry: { grade: 'B' },
            physics: { grade: 'C' },
          }
        end

        let!(:qualification) do
          create(:gcse_qualification,
                 grade: nil,
                 subject: ApplicationQualification::SCIENCE_TRIPLE_AWARD,
                 constituent_grades: science_triple_awards,
                 application_form: application_choice.application_form)
        end

        it 'are mapped correctly' do
          expect(qualification_for(presenter, :gcses, ApplicationQualification::SCIENCE_TRIPLE_AWARD)[:subject_code])
            .to eq(A_AND_AS_LEVEL_SUBJECTS_TO_CODES['Science'])
        end
      end

      context 'gcse english qualifications' do
        let!(:qualification) do
          create(:gcse_qualification,
                 grade: nil,
                 subject: 'english',
                 constituent_grades: {
                   english_language: { grade: 'E', public_id: 1 },
                   english_literature: { grade: 'E', public_id: 2 },
                 },
                 application_form: application_choice.application_form)
        end

        it 'are mapped correctly' do
          expect(qualification_for(presenter, :gcses, 'English language')[:subject_code])
            .to eq(A_AND_AS_LEVEL_SUBJECTS_TO_CODES['English Language'])
          expect(qualification_for(presenter, :gcses, 'English literature')[:subject_code])
            .to eq(A_AND_AS_LEVEL_SUBJECTS_TO_CODES['English Literature'])
        end
      end

      context 'gcse level maths qualifications' do
        let!(:qualification) do
          create(:gcse_qualification,
                 grade: 'A',
                 subject: 'maths',
                 application_form: application_choice.application_form)
        end

        it 'are mapped correctly' do
          expect(qualification_for(presenter, :gcses, 'maths')[:subject_code])
            .to eq(A_AND_AS_LEVEL_SUBJECTS_TO_CODES['Mathematics'])
        end
      end

      context 'other GCSE qualifications' do
        let!(:qualification) do
          create(:other_qualification,
                 grade: 'B',
                 subject: GCSE_SUBJECTS.sample,
                 qualification_type: 'GCSE',
                 application_form: application_choice.application_form)
        end

        it 'are mapped correctly from the autocomplete list' do
          expect(qualification_for(presenter, :other_qualifications, qualification.subject)[:subject_code])
            .to eq(GCSE_SUBJECTS_TO_CODES[qualification.subject])
        end
      end

      context 'A level qualifications' do
        let!(:qualification) do
          create(:other_qualification,
                 grade: 'C',
                 subject: A_AND_AS_LEVEL_SUBJECTS.sample,
                 qualification_type: 'A level',
                 application_form: application_choice.application_form)
        end

        it 'are mapped correctly from the autocomplete list' do
          expect(qualification_for(presenter, :other_qualifications, qualification.subject)[:subject_code])
            .to eq(A_AND_AS_LEVEL_SUBJECTS_TO_CODES[qualification.subject])
        end
      end

      context 'when the subject is not recognised' do
        let!(:qualification) do
          create(:other_qualification,
                 grade: 'C',
                 subject: 'Harry potter books and films',
                 qualification_type: 'A level',
                 application_form: application_choice.application_form)
        end

        it 'the subject code is blank' do
          expect(qualification_for(presenter, :other_qualifications, qualification.subject)[:subject_code]).to be_nil
        end
      end
    end

    context 'GCSE science' do
      let(:science_triple_awards) do
        {
          biology: { grade: 'A' },
          chemistry: { grade: 'B' },
          physics: { grade: 'C' },
        }
      end
      let!(:qualification) do
        create(:gcse_qualification,
               public_id: 4,
               grade: nil,
               subject: ApplicationQualification::SCIENCE_TRIPLE_AWARD,
               constituent_grades: science_triple_awards,
               application_form: application_choice.application_form)
      end

      it 'adds triple award information' do
        gcse = qualification_for(presenter, :gcses, qualification.subject)

        expect(gcse[:id]).to eq 4
        expect(gcse[:grade]).to eq 'ABC'
      end
    end

    context 'English GCSE' do
      let!(:qualification) do
        create(:gcse_qualification,
               subject: 'english',
               grade: nil,
               constituent_grades: {
                 english_language: { grade: 'E', public_id: 1 },
                 english_literature: { grade: 'E', public_id: 2 },
                 'Cockney Rhyming Slang': { grade: 'A*', public_id: 3 },
               },
               award_year: 2006,
               predicted_grade: false,
               application_form: application_choice.application_form)
      end

      it 'parses structured grades' do
        expect(qualification_for(presenter, :gcses, 'English language').slice(:id, :grade).values).to eq([1, 'E'])
        expect(qualification_for(presenter, :gcses, 'English literature').slice(:id, :grade).values).to eq([2, 'E'])
        expect(qualification_for(presenter, :gcses, 'Cockney rhyming slang').slice(:id, :grade).values).to eq([3, 'A*'])
      end
    end

    context 'with legacy invalid qualification types' do
      let!(:qualification) do
        create(
          :gcse_qualification,
          :non_uk,
          application_form: application_choice.application_form,
        )
      end

      let(:long_value) { SecureRandom.alphanumeric(ApplicationQualification::MAX_QUALIFICATION_TYPE_LENGTH + 100) }

      before do
        qualification.update_column(:qualification_type, long_value)
        qualification.update_column(:non_uk_qualification_type, long_value)
      end

      it 'truncates excessively long qualification_type and non_uk_qualification_type values' do
        expect(presenter.qualifications[:gcses][0][:qualification_type].length).to eq(ApplicationQualification::MAX_QUALIFICATION_TYPE_LENGTH)
        expect(presenter.qualifications[:gcses][0][:non_uk_qualification_type].length).to eq(ApplicationQualification::MAX_QUALIFICATION_TYPE_LENGTH)
      end
    end
  end
end
