require 'rails_helper'

RSpec.describe CandidateInterface::EnglishProficiencies::IeltsForm,
               feature_flag: '2027_application_form_has_many_english_proficiencies',
               type: :model do
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
      expect(form.errors.full_messages).to eq  ['Award year Assessment year cannot be before 1980', 'Award year Assessment year must be a real year']
    end

    it 'is invalid if given letters' do
      form = valid_form.tap { |f| f.award_year = 'bbbb' }

      expect(form).not_to be_valid
      expect(form.errors.full_messages).to eq  ['Award year Assessment year must be a real year', 'Award year Assessment year must be a real year']
    end

    it 'is invalid if given a float' do
      form = valid_form.tap { |f| f.award_year = '199.5' }

      expect(form).not_to be_valid
      expect(form.errors.full_messages).to eq  ['Award year Assessment year must be a real year', 'Award year Assessment year must be a real year', 'Award year Enter a single award year']
    end

    it 'is invalid if award year is before ielts was introduced' do
      form = valid_form.tap { |f| f.award_year = 1979 }

      expect(form).not_to be_valid
      expect(form.errors.full_messages).to eq ['Award year Assessment year cannot be before 1980']
    end

    it 'is invalid if given a future year' do
      form = valid_form.tap { |f| f.award_year = Time.zone.today.year.to_i + 1 }

      expect(form).not_to be_valid
      expect(form.errors.full_messages).to eq ['Award year Assessment year cannot be in the future']
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

      expect(form.save).to be false
    end

    it 'raises an error if no application_form present' do
      expect { valid_form.save }.to raise_error(
        CandidateInterface::EnglishProficiencies::MissingApplicationFormError,
      )
    end

    it 'raises an error if no english_proficiency is present' do
      application_form = create(:application_form)
      valid_form.application_form = application_form

      expect { valid_form.save }.to raise_error(
        CandidateInterface::EnglishProficiencies::MissingEnglishProficiencyFormError,
      )
    end

    it 'saves the IELTS qualification' do
      application_form = create(:application_form)
      english_proficiency = create(:english_proficiency, :draft, application_form:, has_qualification: true)

      valid_form.application_form = application_form
      valid_form.english_proficiency = english_proficiency

      valid_form.save
      application_form.reload

      expect(application_form.english_proficiency.qualification_statuses).to contain_exactly('has_qualification')
      expect(application_form.english_proficiency.draft).to be false

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
        english_proficiency = create(:english_proficiency, :draft, application_form:, has_qualification: true)

        valid_form_2.application_form = application_form
        valid_form_2.english_proficiency = english_proficiency

        valid_form_2.save

        expect(application_form.english_proficiency.qualification_statuses).to contain_exactly('has_qualification')
        qualification = application_form.english_proficiency.efl_qualification

        expect(qualification.band_score).to eq '6.0'
        expect(application_form.english_proficiency.draft).to be false
      end
    end

    context 'application_form already has an EnglishProficiency record' do
      it 'replaces the record' do
        application_form = create(:application_form)
        english_proficiency = create(
          :english_proficiency,
          :with_ielts_qualification,
          application_form:,
          has_qualification: true,
          efl_qualification: create(:ielts_qualification, band_score: '2'),
        )

        valid_form.application_form = application_form
        valid_form.english_proficiency = english_proficiency
        valid_form.band_score = '8.5'
        valid_form.save

        expect(application_form.english_proficiency.qualification_statuses).to contain_exactly('has_qualification')
        expect(application_form.english_proficiency.draft).to be false

        expect(application_form.english_proficiency.efl_qualification.band_score).to eq '8.5'
        expect(EnglishProficiency.count).to eq 1
        expect(IeltsQualification.count).to eq 1
      end
    end
  end

  describe '#fill' do
    let(:valid_form) do
      described_class.new(
        english_proficiency:,
      )
    end
    let(:english_proficiency) do
      create(
        :english_proficiency,
        :with_ielts_qualification,
        has_qualification: true,
        efl_qualification:,
      )
    end
    let(:efl_qualification) { create(:ielts_qualification, band_score: '2') }

    it 'assigns the qualification attributes to the form' do
      form = valid_form.fill
      expect(form.band_score).to eq('2')
      expect(form.trf_number).to eq(efl_qualification.trf_number)
      expect(form.award_year).to eq(efl_qualification.award_year)
    end

    context 'when the efl qualification is not an IeltsQualification' do
      let(:efl_qualification) { create(:toefl_qualification) }

      it 'does not assign the qualification attributes to the form' do
        form = valid_form.fill
        expect(form.band_score).to be_nil
        expect(form.trf_number).to be_nil
        expect(form.award_year).to be_nil
      end
    end
  end
end
