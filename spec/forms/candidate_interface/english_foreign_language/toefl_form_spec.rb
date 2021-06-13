require 'rails_helper'

RSpec.describe CandidateInterface::EnglishForeignLanguage::ToeflForm, type: :model do
  let(:valid_form) do
    described_class.new(
      registration_number: '12345',
      total_score: '20',
      award_year: 2000,
    )
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(valid_form).to be_valid
    end

    it 'is invalid if missing any required attributes' do
      form = valid_form.tap { |f| f.registration_number = nil }

      expect(form).not_to be_valid
      expect(form.errors.full_messages).to eq ['Registration number Enter your registration number']
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

    it 'saves the TOEFL qualification' do
      application_form = create(:application_form)
      valid_form.application_form = application_form

      valid_form.save

      expect(application_form.english_proficiency.qualification_status).to eq 'has_qualification'
      qualification = application_form.english_proficiency.efl_qualification
      expect(qualification.registration_number).to eq '12345'
      expect(qualification.total_score).to eq 20
      expect(qualification.award_year).to eq 2000
    end

    context 'application_form already has an EnglishProficiency record' do
      it 'replaces the record' do
        proficiency = create(
          :english_proficiency,
          :with_toefl_qualification,
          efl_qualification: create(:toefl_qualification, total_score: 5),
        )
        application_form = proficiency.application_form

        valid_form.application_form = application_form
        valid_form.total_score = 25
        valid_form.save

        expect(application_form.english_proficiency.efl_qualification.total_score).to eq 25
        expect(EnglishProficiency.count).to eq 1
        expect(ToeflQualification.count).to eq 1
      end
    end
  end
end
