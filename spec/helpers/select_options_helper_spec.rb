require 'rails_helper'

RSpec.describe SelectOptionsHelper, type: :helper do
  describe '#select_nationality_options' do
    it 'returns a structured list of all non-British and Irish nationalities' do
      _, nationality = NATIONALITIES.reject { |code, _| %w[GB IE].include?(code) }.sample

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

    it 'excludes Irish and British nationalities by default' do
      NATIONALITIES.select { |code, _| %w[GB IE].include?(code) }.each do |_, nationality|
        expect(select_nationality_options).not_to include(
          OpenStruct.new(
            id: nationality,
            name: nationality,
          ),
        )
      end
    end

    it 'includes Irish and British nationalities when `include_british_and_irish` option is true' do
      NATIONALITIES.select { |code, _| %w[GB IE].include?(code) }.each do |_, nationality|
        expect(select_nationality_options(include_british_and_irish: true)).to include(
          OpenStruct.new(
            id: nationality,
            name: nationality,
          ),
        )
      end
    end
  end

  describe '#select_country_options' do
    it 'returns a structured list of countries' do
      expect(select_country_options).to include(
        OpenStruct.new(
          id: '',
          name: t('application_form.contact_information.country.default_option'),
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
