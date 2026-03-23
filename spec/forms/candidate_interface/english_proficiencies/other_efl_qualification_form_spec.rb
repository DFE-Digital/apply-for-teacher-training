require 'rails_helper'

RSpec.describe CandidateInterface::EnglishProficiencies::OtherEflQualificationForm,
               feature_flag: '2027_application_form_has_many_english_proficiencies',
               type: :model do
  let(:valid_form) do
    described_class.new(
      name: 'Some Rando English Test',
      grade: '6',
      award_year: 2000,
    )
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(valid_form).to be_valid
    end

    it 'is invalid if missing any required attributes' do
      form = valid_form.tap { |f| f.name = nil }

      expect(form).not_to be_valid
      expect(form.errors.full_messages).to eq ['Name Enter assessment name']
    end

    it 'is invalid if given an invalid year' do
      form = valid_form.tap { |f| f.award_year = 111 }

      expect(form).not_to be_valid
      expect(form.errors.full_messages).to eq  ['Award year Assessment year must be a real year']
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

    it 'is is future year if given a future year' do
      form = valid_form.tap { |f| f.award_year = Time.zone.today.year.to_i + 1 }

      expect(form).not_to be_valid
      expect(form.errors.full_messages).to eq ['Award year Assessment year cannot be in the future']
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

    it 'saves the qualification' do
      application_form = create(:application_form)
      english_proficiency = create(:english_proficiency, :draft, application_form:, has_qualification: true)

      valid_form.application_form = application_form
      valid_form.english_proficiency = english_proficiency

      valid_form.save
      application_form.reload

      expect(application_form.english_proficiency.qualification_statuses).to contain_exactly 'has_qualification'
      qualification = application_form.english_proficiency.efl_qualification
      expect(qualification.name).to eq 'Some Rando English Test'
      expect(qualification.grade).to eq '6'
      expect(qualification.award_year).to eq 2000
    end

    context 'application_form already has an EnglishProficiency record' do
      it 'replaces the record' do
        application_form = create(:application_form)
        proficiency = create(
          :english_proficiency,
          :with_other_efl_qualification,
          application_form:,
          has_qualification: true,
        )
        expect(proficiency.efl_qualification.grade).to eq '10'

        valid_form.application_form = application_form
        valid_form.english_proficiency = proficiency
        valid_form.grade = 'A+'
        valid_form.save

        expect(application_form.english_proficiency.efl_qualification.grade).to eq 'A+'
        expect(EnglishProficiency.count).to eq 1
        expect(OtherEflQualification.count).to eq 1
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
        :with_other_efl_qualification,
        has_qualification: true,
        efl_qualification:,
      )
    end
    let(:efl_qualification) { create(:other_efl_qualification) }

    it 'assigns the qualification attributes to the form' do
      form = valid_form.fill
      expect(form.name).to eq(efl_qualification.name)
      expect(form.grade).to eq(efl_qualification.grade)
      expect(form.award_year).to eq(efl_qualification.award_year)
    end

    context 'when the efl qualification is not an OtherEflQualification' do
      let(:efl_qualification) { create(:toefl_qualification) }

      it 'does not assign the qualification attributes to the form' do
        form = valid_form.fill
        expect(form.name).to be_nil
        expect(form.grade).to be_nil
        expect(form.award_year).to be_nil
      end
    end
  end
end
