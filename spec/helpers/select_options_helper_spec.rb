require 'rails_helper'

RSpec.describe SelectOptionsHelper, type: :helper do
  describe '#select_nationality_options' do
    it 'returns a structured list of nationalities' do
      _, nationality = NATIONALITIES.sample

      expect(select_nationality_options).to include(
        OpenStruct.new(
          id: '',
          name: t('application_form.personal_details.nationality.default_option'),
        ),
      )
      expect(select_nationality_options).to include(
        OpenStruct.new(
          id: nationality,
          name: nationality,
        ),
      )
    end
  end

  describe '#select_country_options' do
    it 'returns a structured list of countries' do
      expect(select_country_options).to include(
        OpenStruct.new(
          id: '',
          name: t('application_form.contact_details.country.default_option'),
        ),
      )
      expect(select_country_options).to include(
        OpenStruct.new(
          id: 'FR',
          name: 'France',
        ),
      )
      expect(select_country_options).not_to include(
        OpenStruct.new(
          id: 'GB',
          name: 'United Kingdom',
        ),
      )
    end
  end
end
