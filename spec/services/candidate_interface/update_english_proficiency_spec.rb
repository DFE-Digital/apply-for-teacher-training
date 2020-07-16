require 'rails_helper'

RSpec.describe CandidateInterface::UpdateEnglishProficiency do
  describe '#call' do
    context 'given args for a qualification' do
      let(:application_form) { create(:application_form) }
      let(:ielts) { build(:ielts_qualification) }
      let(:update_service) do
        described_class.new(
          application_form,
          qualification_status: :has_qualification,
          efl_qualification: ielts,
        )
      end

      it 'creates an EnglishProficiency record for the given qualification' do
        update_service.call

        expect(application_form.english_proficiency.efl_qualification.trf_number).to eq ielts.trf_number
        expect(EnglishProficiency.count).to eq 1
        expect(IeltsQualification.count).to eq 1
      end

      context 'when an EnglishProficiency record already exists' do
        before do
          proficiency = create(
            :english_proficiency,
            :with_toefl_qualification,
          )
          application_form.update!(english_proficiency: proficiency)
        end

        it 'replaces the existing record' do
          expect(EnglishProficiency.count).to eq 1
          expect(IeltsQualification.count).to eq 0
          expect(ToeflQualification.count).to eq 1

          update_service.call

          expect(EnglishProficiency.count).to eq 1
          expect(IeltsQualification.count).to eq 1
          expect(ToeflQualification.count).to eq 0
        end
      end
    end

    context 'given args for no qualification' do
      let(:application_form) { create(:application_form) }
      let(:update_service) do
        described_class.new(
          application_form,
          qualification_status: :no_qualification,
          no_qualification_details: 'Waiting for my results.',
        )
      end

      it 'creates an EnglishProficiency record reflecting the lack of a qualification' do
        update_service.call

        expect(application_form.english_proficiency).to be_no_qualification
        expect(application_form.english_proficiency.no_qualification_details).to eq(
          'Waiting for my results.',
        )
      end

      context 'when an EnglishProficiency record already exists' do
        before do
          proficiency = create(
            :english_proficiency,
            :with_toefl_qualification,
          )
          application_form.update!(english_proficiency: proficiency)
        end

        it 'replaces the existing record' do
          expect(EnglishProficiency.count).to eq 1
          expect(ToeflQualification.count).to eq 1
          expect(application_form.english_proficiency).to be_has_qualification

          update_service.call

          expect(EnglishProficiency.count).to eq 1
          expect(ToeflQualification.count).to eq 0
          expect(application_form.english_proficiency).to be_no_qualification
        end
      end
    end

    context 'given args for qualification not needed' do
      let(:application_form) { create(:application_form) }
      let(:update_service) do
        described_class.new(
          application_form,
          qualification_status: :qualification_not_needed,
        )
      end

      it 'creates an EnglishProficiency record reflecting that no qualification is needed' do
        update_service.call

        expect(application_form.english_proficiency).to be_qualification_not_needed
        expect(application_form.english_proficiency.no_qualification_details).to be_blank
      end

      context 'when an EnglishProficiency record already exists' do
        before do
          proficiency = create(
            :english_proficiency,
            :with_toefl_qualification,
          )
          application_form.update!(english_proficiency: proficiency)
        end

        it 'replaces the existing record' do
          expect(EnglishProficiency.count).to eq 1
          expect(ToeflQualification.count).to eq 1
          expect(application_form.english_proficiency).to be_has_qualification

          update_service.call

          expect(EnglishProficiency.count).to eq 1
          expect(ToeflQualification.count).to eq 0
          expect(application_form.english_proficiency).to be_qualification_not_needed
        end
      end
    end
  end
end
