require 'rails_helper'

RSpec.describe CandidateInterface::NationalitiesForm, type: :model do
  let(:data) do
    {
      first_nationality: NATIONALITY_DEMONYMS.sample,
      second_nationality: NATIONALITY_DEMONYMS.sample,
    }
  end

  let(:form_data) do
    {
      first_nationality: data[:first_nationality],
      second_nationality: data[:second_nationality],
    }
  end

  describe '.build_from_application' do
    let(:data) do
      {
        first_nationality: 'British',
        second_nationality: 'Irish',
        third_nationality: 'Welsh',
        fourth_nationality: 'Northern Irish',
        fifth_nationality: 'Scottish',
      }
    end

    let(:form_data) do
      {
        nationalities: [data[:first_nationality], data[:second_nationality], 'other'],
        other_nationality1: data[:third_nationality],
        other_nationality2: data[:fourth_nationality],
        other_nationality3: data[:fifth_nationality],
      }
    end

    it 'creates an object based on the provided ApplicationForm' do
      application_form = ApplicationForm.new(data)
      nationalities = described_class.build_from_application(
        application_form,
      )

      expect(nationalities).to have_attributes(form_data)
    end
  end

  describe '.candidates_nationalties' do
    context 'when other is true' do
      it 'returns a unique array of the candidates selected nationalties' do
        nationalities = described_class.new(
          british: 'British',
          irish: 'Irish',
          other: 'other',
          other_nationality1: 'British',
          other_nationality2: 'German',
          other_nationality3: 'Swedish',
        )
        expect(nationalities.candidates_nationalities).to match_array %w[British Irish German Swedish]
      end
    end

    context 'when other is nil' do
      it 'returns a unique array of the candidates selected nationalties' do
        nationalities = described_class.new(
          british: 'British',
          irish: 'Irish',
          other: nil,
          other_nationality1: 'British',
          other_nationality2: 'German',
          other_nationality3: 'Swedish',
        )
        expect(nationalities.candidates_nationalities).to match_array %w[British Irish]
      end
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      nationalities = described_class.new

      expect(nationalities.save(ApplicationForm.new)).to eq(false)
    end

    context 'when the candidate is British or Irish' do
      let(:form_data) do
        {
          british: 'British',
          irish: 'Irish',
          other: 'other',
          other_nationality1: 'Belgian',
          other_nationality2: 'German',
          other_nationality3: 'Swedish',
        }
      end

      it 'updates the provided ApplicationForms nationalities and resets the right to work fields to nil' do
        application_form = FactoryBot.build(:application_form, right_to_work_or_study: 'yes', right_to_work_or_study_details: 'I have a visa.')
        nationalities = described_class.new(form_data)

        expect(nationalities.save(application_form)).to eq(true)
        expect(application_form.first_nationality).to eq 'British'
        expect(application_form.second_nationality).to eq 'Irish'
        expect(application_form.third_nationality).to eq 'Belgian'
        expect(application_form.fourth_nationality).to eq 'German'
        expect(application_form.fifth_nationality).to eq 'Swedish'
        expect(application_form.right_to_work_or_study).to eq nil
        expect(application_form.right_to_work_or_study_details).to eq nil
      end
    end

    context 'when the candidate is not British or Irish' do
      let(:form_data) do
        {
          other: 'other',
          other_nationality1: 'Belgian',
          other_nationality2: 'German',
          other_nationality3: 'Swedish',
        }
      end

      it 'updates the provided ApplicationForms nationalities and retains the right to work fields' do
        application_form = FactoryBot.build(:application_form, right_to_work_or_study: 'yes', right_to_work_or_study_details: 'I have a visa.')
        nationalities = described_class.new(form_data)

        expect(nationalities.save(application_form)).to eq(true)
        expect(application_form.first_nationality).to eq 'Belgian'
        expect(application_form.second_nationality).to eq 'German'
        expect(application_form.third_nationality).to eq 'Swedish'
        expect(application_form.right_to_work_or_study).to eq 'yes'
        expect(application_form.right_to_work_or_study_details).to eq 'I have a visa.'
      end
    end
  end

  describe 'validations' do
    context 'with no nationality option selected' do
      it 'validates the candidate has provided a nationality' do
        details_with_invalid_nationality = described_class.new

        details_with_invalid_nationality.validate

        expect(details_with_invalid_nationality.errors.attribute_names).to include :nationalities
      end
    end

    context "with 'Other' nationality option selected but first nationality is not selected" do
      it 'validates the candidate has provided a first nationality' do
        details_with_invalid_nationality = described_class.new(other: 'other')

        details_with_invalid_nationality.validate

        expect(details_with_invalid_nationality.errors.attribute_names).not_to include :other
        expect(details_with_invalid_nationality.errors.attribute_names).to include :other_nationality1
      end
    end

    context "with 'Other' nationality option and and first nationality selected" do
      it 'is valid' do
        details_with_valid_nationality = described_class.new(
          other: 'other',
          other_nationality1: 'New Zealander',
        )

        expect(details_with_valid_nationality).to be_valid
      end
    end

    it 'validates nationalities against the NATIONALITY_DEMONYMS list' do
      details_with_invalid_nationality = described_class.new(
        other_nationality1: 'Tralfamadorian',
        other_nationality2: NATIONALITY_DEMONYMS.sample,
        other_nationality3: 'Tribbel',
      )

      details_with_valid_nationality = described_class.new(
        other_nationality1: NATIONALITY_DEMONYMS.sample,
        other_nationality2: NATIONALITY_DEMONYMS.sample,
        other_nationality3: NATIONALITY_DEMONYMS.sample,
      )

      details_with_valid_nationality.validate
      details_with_invalid_nationality.validate

      expect(details_with_valid_nationality.errors.attribute_names).not_to include :other_nationality1
      expect(details_with_valid_nationality.errors.attribute_names).not_to include :other_nationality2
      expect(details_with_valid_nationality.errors.attribute_names).not_to include :other_nationality3

      expect(details_with_invalid_nationality.errors.attribute_names).to include :other_nationality1
      expect(details_with_invalid_nationality.errors.attribute_names).not_to include :other_nationality2
      expect(details_with_invalid_nationality.errors.attribute_names).to include :other_nationality3
    end
  end
end
