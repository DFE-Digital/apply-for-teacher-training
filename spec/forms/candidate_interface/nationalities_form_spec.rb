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
    context 'with the international_personal_details flag off' do
      it 'creates an object based on the provided ApplicationForm' do
        application_form = ApplicationForm.new(data)
        nationalities = CandidateInterface::NationalitiesForm.build_from_application(
          application_form,
        )
        expect(nationalities).to have_attributes(form_data)
      end
    end

    context 'with the international_personal_details flag on' do
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
          british: data[:first_nationality],
          irish: data[:second_nationality],
          other: true,
          other_nationality1: data[:third_nationality],
          other_nationality2: data[:fourth_nationality],
          other_nationality3: data[:fifth_nationality],
        }
      end

      before { FeatureFlag.activate('international_personal_details') }

      it 'creates an object based on the provided ApplicationForm' do
        application_form = ApplicationForm.new(data)
        nationalities = CandidateInterface::NationalitiesForm.build_from_application(
          application_form,
        )

        expect(nationalities).to have_attributes(form_data)
      end
    end
  end

  describe '.candidates_nationalties' do
    context 'when other is true' do
      it 'returns a unique array of the candidates selected nationalties' do
        nationalities = CandidateInterface::NationalitiesForm.new(
          british: 'British',
          irish: 'Irish',
          other: true,
          other_nationality1: 'British',
          other_nationality2: 'German',
          other_nationality3: 'Swedish',
        )
        expect(nationalities.candidates_nationalties).to match_array %w[British Irish German Swedish]
      end
    end

    context 'when other is nil' do
      it 'returns a unique array of the candidates selected nationalties' do
        nationalities = CandidateInterface::NationalitiesForm.new(
          british: 'British',
          irish: 'Irish',
          other: nil,
          other_nationality1: 'British',
          other_nationality2: 'German',
          other_nationality3: 'Swedish',
        )
        expect(nationalities.candidates_nationalties).to match_array %w[British Irish]
      end
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      nationalities = CandidateInterface::NationalitiesForm.new

      expect(nationalities.save(ApplicationForm.new)).to eq(false)
    end

    context 'with the international_personal_details flag off' do
      it 'updates the provided ApplicationForm if valid' do
        application_form = FactoryBot.create(:application_form)
        nationalities = CandidateInterface::NationalitiesForm.new(form_data)

        expect(nationalities.save(application_form)).to eq(true)
        expect(application_form).to have_attributes(data)
      end
    end

    context 'when the international_personal_details flag on' do
      let(:form_data) do
        {
          british: 'British',
          irish: 'Irish',
          other: true,
          other_nationality1: 'Belgian',
          other_nationality2: 'German',
          other_nationality3: 'Swedish',
        }
      end

      it 'updates the provided ApplicationForms nationalties' do
        FeatureFlag.activate('international_personal_details')
        application_form = FactoryBot.create(:application_form)
        nationalities = CandidateInterface::NationalitiesForm.new(form_data)

        expect(nationalities.save(application_form)).to eq(true)
        expect(application_form.first_nationality).to eq 'British'
        expect(application_form.second_nationality).to eq 'Irish'
        expect(application_form.third_nationality).to eq 'Belgian'
        expect(application_form.fourth_nationality).to eq 'German'
        expect(application_form.fifth_nationality).to eq 'Swedish'
      end
    end
  end

  describe 'validations' do
    context 'with the international_personal_details flag off' do
      it { is_expected.to validate_presence_of(:first_nationality) }

      it 'validates nationalities against the NATIONALITY_DEMONYMS list' do
        details_with_invalid_nationality = CandidateInterface::NationalitiesForm.new(
          first_nationality: 'Tralfamadorian',
          second_nationality: 'Czechoslovakian',
        )

        details_with_valid_nationality = CandidateInterface::NationalitiesForm.new(
          first_nationality: NATIONALITY_DEMONYMS.sample,
          second_nationality: NATIONALITY_DEMONYMS.sample,
        )

        details_with_valid_nationality.validate
        details_with_invalid_nationality.validate

        expect(details_with_valid_nationality.errors.keys).not_to include :first_nationality
        expect(details_with_valid_nationality.errors.keys).not_to include :second_nationality

        expect(details_with_invalid_nationality.errors.keys).to include :first_nationality
        expect(details_with_invalid_nationality.errors.keys).to include :second_nationality
      end
    end

    context 'with the international_personal_details flag on' do
      before do
        FeatureFlag.activate('international_personal_details')
      end

      it 'validates the candidate has provided a nationality' do
      end

      it 'validates nationalities against the NATIONALITY_DEMONYMS list' do
        details_with_invalid_nationality = CandidateInterface::NationalitiesForm.new(
          other_nationality1: 'Tralfamadorian',
          other_nationality2: NATIONALITY_DEMONYMS.sample,
          other_nationality3: 'Tribbel',
        )

        details_with_valid_nationality = CandidateInterface::NationalitiesForm.new(
          other_nationality1: NATIONALITY_DEMONYMS.sample,
          other_nationality2: NATIONALITY_DEMONYMS.sample,
          other_nationality3: NATIONALITY_DEMONYMS.sample,
        )

        details_with_valid_nationality.validate
        details_with_invalid_nationality.validate

        expect(details_with_valid_nationality.errors.keys).not_to include :other_nationality1
        expect(details_with_valid_nationality.errors.keys).not_to include :other_nationality2
        expect(details_with_valid_nationality.errors.keys).not_to include :other_nationality3

        expect(details_with_invalid_nationality.errors.keys).to include :other_nationality1
        expect(details_with_invalid_nationality.errors.keys).not_to include :other_nationality2
        expect(details_with_invalid_nationality.errors.keys).to include :other_nationality3
      end
    end
  end
end
