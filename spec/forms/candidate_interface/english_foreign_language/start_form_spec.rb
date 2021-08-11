require 'rails_helper'

RSpec.describe CandidateInterface::EnglishForeignLanguage::StartForm, type: :model do
  describe '#save' do
    let(:valid_form) do
      described_class.new(qualification_status: 'has_qualification')
    end

    it 'returns false if not valid' do
      valid_form.qualification_status = nil

      expect(valid_form.save).to eq false
    end

    it 'raises an error if no application_form present' do
      expect { valid_form.save }.to raise_error(
        CandidateInterface::EnglishForeignLanguage::MissingApplicationFormError,
      )
    end

    context 'when qualification_status is "has_qualification"' do
      it 'returns true' do
        valid_form.application_form = build(:application_form)
        expect(valid_form.save).to eq true
      end
    end

    context 'when qualification_status is "qualification_not_needed"' do
      before { valid_form.qualification_status = 'qualification_not_needed' }

      it 'creates the appropriate EnglishProficiency record' do
        application_form = create(:application_form)
        valid_form.application_form = application_form

        valid_form.save

        expect(application_form.english_proficiency).to be_qualification_not_needed
      end
    end

    context 'when qualification_status is "no_qualification"' do
      before do
        valid_form.qualification_status = 'no_qualification'
        valid_form.no_qualification_details = 'Work in progress'
      end

      it 'creates the appropriate EnglishProficiency record' do
        application_form = create(:application_form)
        valid_form.application_form = application_form

        valid_form.save

        expect(application_form.english_proficiency).to be_no_qualification
        expect(application_form.english_proficiency.no_qualification_details).to eq 'Work in progress'
      end
    end
  end

  describe '#next_path' do
    context 'when qualification_status is "has_qualification"' do
      let(:form) { described_class.new(qualification_status: 'has_qualification') }

      it 'returns path for selecting qualification type' do
        expect(form.next_path).to eq '/candidate/application/english-as-a-foreign-language/type'
      end

      context 'when `return_to` is set' do
        let(:form) { described_class.new(qualification_status: 'has_qualification', return_to: 'application-review') }

        it 'returns path for selecting qualification type with `return-to` parameter' do
          expect(form.next_path).to eq '/candidate/application/english-as-a-foreign-language/type?return-to=application-review'
        end
      end
    end

    context 'when qualification_status is "no_qualification"' do
      let(:form) { described_class.new(qualification_status: 'no_qualification') }

      it 'returns path for review page' do
        expect(form.next_path).to eq '/candidate/application/english-as-a-foreign-language/review'
      end
    end

    context 'when qualification_status is "qualification_not_needed"' do
      let(:form) { described_class.new(qualification_status: 'qualification_not_needed') }

      it 'returns path for review page' do
        expect(form.next_path).to eq '/candidate/application/english-as-a-foreign-language/review'
      end
    end
  end
end
