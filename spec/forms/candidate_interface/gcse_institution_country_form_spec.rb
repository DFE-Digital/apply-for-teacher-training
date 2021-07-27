require 'rails_helper'

RSpec.describe CandidateInterface::GcseInstitutionCountryForm, type: :model do
  let(:form_data) { { institution_country: COUNTRIES.keys.sample } }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:institution_country) }

    it 'validates nationalities against the COUNTRIES list' do
      invalid_country = described_class.new(
        institution_country: 'QQ',
      )
      valid_country = described_class.new(
        institution_country: COUNTRIES.keys.sample,
      )
      valid_country.validate
      invalid_country.validate
      expect(valid_country.errors.attribute_names).not_to include :institution_country
      expect(invalid_country.errors.attribute_names).to include :institution_country
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

      expect(institution_country_form.save(ApplicationQualification.new)).to eq(false)
    end

    it 'updates the provided ApplicationForm if valid' do
      application_qualification = build(:application_qualification)
      institution_country_form = described_class.new(form_data)

      expect(institution_country_form.save(application_qualification)).to eq(true)
      expect(application_qualification.institution_country).to eq form_data[:institution_country]
    end
  end
end
