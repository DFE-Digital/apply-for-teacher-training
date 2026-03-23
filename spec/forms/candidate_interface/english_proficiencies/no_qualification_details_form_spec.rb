require 'rails_helper'

RSpec.describe CandidateInterface::EnglishProficiencies::NoQualificationDetailsForm,
               feature_flag: '2027_application_form_has_many_english_proficiencies',
               type: :model do
  let(:valid_form) do
    described_class.new(
      declare_no_qualification_details: 1,
      no_qualification_details: 'Work in progress',
    )
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(valid_form).to be_valid
    end

    it 'is valid if declare_no_qualification_details is 0 and no details are given' do
      form = valid_form.tap do |f|
        f.declare_no_qualification_details = 0
        f.no_qualification_details = nil
      end

      expect(form).to be_valid
    end

    it 'is invalid if declare_no_qualification_details is 1 and no details are given' do
      form = valid_form.tap do |f|
        f.declare_no_qualification_details = 1
        f.no_qualification_details = nil
      end

      expect(form).not_to be_valid
      expect(
        form.errors.full_messages,
      ).to eq ['No qualification details Enter the details of the assessment you plan to take']
    end

    it 'is invalid if declare_no_qualification_details is not given' do
      form = valid_form.tap do |f|
        f.declare_no_qualification_details = nil
      end

      expect(form).not_to be_valid
      expect(
        form.errors.full_messages,
      ).to eq ['Declare no qualification details Select if you plan to do an English as a foreign language assessment']
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

    it 'saves the no qualification details' do
      application_form = create(:application_form)
      english_proficiency = create(:english_proficiency, :draft, application_form:, no_qualification: true)

      valid_form.application_form = application_form
      valid_form.english_proficiency = english_proficiency

      valid_form.save
      application_form.reload

      expect(application_form.english_proficiency.qualification_statuses).to contain_exactly('no_qualification')
      expect(application_form.english_proficiency.draft).to be false
      expect(application_form.english_proficiency.no_qualification_details).to eq('Work in progress')
    end

    context 'user does not enter any no qualification details' do
      let(:valid_form_2) do
        described_class.new(
          declare_no_qualification_details: 0,
          no_qualification_details: nil,
        )
      end

      it 'saves the no qualification details' do
        application_form = create(:application_form)
        english_proficiency = create(:english_proficiency, :draft, application_form:, no_qualification: true)

        valid_form_2.application_form = application_form
        valid_form_2.english_proficiency = english_proficiency

        valid_form_2.save
        application_form.reload

        expect(application_form.english_proficiency.qualification_statuses).to contain_exactly('no_qualification')
        expect(application_form.english_proficiency.draft).to be false
        expect(application_form.english_proficiency.no_qualification_details).to be_nil
      end
    end
  end

  describe '#fill' do
    let(:valid_form) do
      described_class.new(
        english_proficiency:,
        application_form:,
      )
    end
    let(:application_form) { create(:application_form) }

    context 'when the english proficiency no_qualification_details is nil' do
      let(:english_proficiency) do
        create(
          :english_proficiency,
          application_form:,
          no_qualification: true,
          no_qualification_details: nil,
        )
      end

      it 'assigns 0 to the declare_no_qualification_details attribute' do
        form = valid_form.fill
        expect(form.declare_no_qualification_details).to eq(0)
        expect(form.no_qualification_details).to be_nil
      end
    end

    context 'when the english proficiency no_qualification_details is present' do
      let(:english_proficiency) do
        create(
          :english_proficiency,
          application_form:,
          no_qualification: true,
          no_qualification_details: 'Work in progress',
        )
      end

      it 'assigns 1 to the declare_no_qualification_details,and the no_qualification_details to the form attributes' do
        form = valid_form.fill
        expect(form.declare_no_qualification_details).to eq(1)
        expect(form.no_qualification_details).to eq('Work in progress')
      end
    end
  end
end
