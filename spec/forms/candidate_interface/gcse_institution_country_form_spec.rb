require 'rails_helper'

RSpec.describe CandidateInterface::GcseInstitutionCountryForm, type: :model do
  let(:form_data) { { institution_country: COUNTRIES_BY_NAME.sample } }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:institution_country) }

    it 'validates nationalities against the COUNTRIES_BY_NAME list' do
      invalid_nationality = CandidateInterface::GcseInstitutionCountryForm.new(
        institution_country: 'Tralfamadorian',
      )
      valid_nationality = CandidateInterface::GcseInstitutionCountryForm.new(
        institution_country: COUNTRIES_BY_NAME.sample,
      )
      valid_nationality.validate
      invalid_nationality.validate
      expect(valid_nationality.errors.keys).not_to include :institution_country
      expect(invalid_nationality.errors.keys).to include :institution_country
    end
  end

  describe '#build_from_qualification' do
    it 'sets the institution_country attribute on the form the to qualifications institution_country' do
      application_qualification = create(:application_qualification)
      institution_country_form = CandidateInterface::GcseInstitutionCountryForm.build_from_qualification(application_qualification)

      expect(institution_country_form.institution_country).to eq application_qualification.institution_country
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      institution_country_form = CandidateInterface::GcseInstitutionCountryForm.new

      expect(institution_country_form.save(ApplicationQualification.new)).to eq(false)
    end

    it 'updates the provided ApplicationForm if valid' do
      application_qualification = create(:application_qualification)
      institution_country_form = CandidateInterface::GcseInstitutionCountryForm.new(form_data)

      expect(institution_country_form.save(application_qualification)).to eq(true)
      expect(application_qualification.institution_country).to eq form_data[:institution_country]
    end
  end
end
