require 'rails_helper'

RSpec.describe CandidateInterface::EnglishForeignLanguage::IeltsForm, type: :model do
  let(:valid_form) do
    described_class.new(
      trf_number: '12345',
      band_score: '6.5',
      award_year: 2000,
    )
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(valid_form).to be_valid
    end

    it 'is invalid if missing any required attributes' do
      form = valid_form.tap { |f| f.trf_number = nil }

      expect(form).not_to be_valid
      expect(form.errors.full_messages).to eq ['Trf number Enter your TRF number']
    end

    it 'is invalid if given an invalid year' do
      form = valid_form.tap { |f| f.award_year = 111 }

      expect(form).not_to be_valid
      expect(form.errors.full_messages).to eq ['Award year Enter a real award year']
    end

    it 'is is future year if given a future year' do
      form = valid_form.tap { |f| f.award_year = Time.zone.today.year.to_i + 1 }

      expect(form).not_to be_valid
      expect(form.errors.full_messages).to eq ['Award year Assessment year must be this year or a previous year']
    end

    context 'user inputs single digit band_score' do
      let(:valid_form_2) do
        described_class.new(
          trf_number: '12345',
          band_score: '6',
          award_year: 2000,
        )
      end

      it 'is valid with valid attributes' do
        expect(valid_form).to be_valid
      end
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      form = described_class.new

      expect(form.save).to eq false
    end

    it 'raises an error if no application_form present' do
      expect { valid_form.save }.to raise_error(
        CandidateInterface::EnglishForeignLanguage::MissingApplicationFormError,
      )
    end

    it 'saves the IELTS qualification' do
      application_form = create(:application_form)
      valid_form.application_form = application_form

      valid_form.save

      expect(application_form.english_proficiency.qualification_status).to eq 'has_qualification'
      qualification = application_form.english_proficiency.efl_qualification
      expect(qualification.trf_number).to eq '12345'
      expect(qualification.band_score).to eq '6.5'
      expect(qualification.award_year).to eq 2000
    end

    context 'user inputs single digit band_score' do
      let(:valid_form_2) do
        described_class.new(
          trf_number: '12345',
          band_score: '6',
          award_year: 2000,
        )
      end

      it 'saves a sanitized grade' do
        application_form = create(:application_form)
        valid_form_2.application_form = application_form

        valid_form_2.save

        expect(application_form.english_proficiency.qualification_status).to eq 'has_qualification'
        qualification = application_form.english_proficiency.efl_qualification

        expect(qualification.band_score).to eq '6.0'
      end
    end

    context 'application_form already has an EnglishProficiency record' do
      it 'replaces the record' do
        proficiency = create(
          :english_proficiency,
          :with_ielts_qualification,
          efl_qualification: create(:ielts_qualification, band_score: '2'),
        )
        application_form = proficiency.application_form

        valid_form.application_form = application_form
        valid_form.band_score = '8.5'
        valid_form.save

        expect(application_form.english_proficiency.efl_qualification.band_score).to eq '8.5'
        expect(EnglishProficiency.count).to eq 1
        expect(IeltsQualification.count).to eq 1
      end
    end
  end
end
