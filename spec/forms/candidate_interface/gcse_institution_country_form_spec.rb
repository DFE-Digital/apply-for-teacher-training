require 'rails_helper'

RSpec.describe CandidateInterface::GcseInstitutionCountryForm, type: :model do
  let(:form_data) do
    country_code = COUNTRIES_AND_TERRITORIES.keys.sample

    {
      institution_country: country_code,
      institution_country_raw: CountryFinder.find_name_from_iso_code(country_code),
    }
  end

  describe 'validations' do
    it 'is invalid when no country is entered' do
      form = described_class.new(
        institution_country: '',
        institution_country_raw: '',
      )

      form.validate

      expect(form.errors.details[:institution_country]).to include(error: :blank)
    end

    it 'is invalid when raw input does not match any country' do
      form = described_class.new(
        institution_country: '',
        institution_country_raw: 'iojsocijasoijcod',
      )

      form.validate
      expect(form.errors.details[:institution_country]).to include(error: :inclusion)
    end

    it 'is valid when a country is selected from the list' do
      country_code = COUNTRIES_AND_TERRITORIES.keys.sample

      form = described_class.new(
        institution_country: country_code,
        institution_country_raw: CountryFinder.find_name_from_iso_code(country_code),
      )

      form.validate

      expect(form.errors.attribute_names).not_to include(:institution_country)
    end

    it 'is valid if country can be matched from raw data' do
      form = described_class.new(
        institution_country: '',
        institution_country_raw: 'Ghana',
      )
      expect(form.institution_country).to eq 'GH'
      expect(form.valid?).to be true
    end

    it 'is invalid when the selected country and raw value do not match' do
      form = described_class.new(
        institution_country: 'LA',
        institution_country_raw: 'iojsocijasoijcod',
      )

      form.validate

      expect(form.errors.details[:institution_country]).to include(error: :inclusion)
    end
  end

  describe '#build_from_qualification' do
    it 'sets the institution_country attribute on the form the to qualifications institution_country' do
      application_qualification = build(:application_qualification)
      institution_country_form = described_class.build_from_qualification(application_qualification)

      expect(institution_country_form.institution_country).to eq application_qualification.institution_country
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      institution_country_form = described_class.new

      expect(institution_country_form.save(ApplicationQualification.new)).to be(false)
    end

    it 'updates the provided ApplicationForm if valid' do
      application_qualification = build(:application_qualification)
      institution_country_form = described_class.new(form_data)

      expect(institution_country_form.save(application_qualification)).to be(true)
      expect(application_qualification.institution_country).to eq form_data[:institution_country]
    end
  end
end
