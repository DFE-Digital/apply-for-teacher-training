require 'rails_helper'

RSpec.describe SelectOptionsHelper do
  describe '#select_nationality_options' do
    it 'returns a structured list of all non-British and Irish nationalities' do
      # rubocop:disable Style/HashExcept
      _, nationality = NATIONALITIES.reject { |code, _| %w[GB IE].include?(code) }.sample
      # rubocop:enable Style/HashExcept

      expect(select_nationality_options).to include(
        SelectOptionsHelper::Option.new('', t('application_form.personal_details.nationality.default_option')),
      )
      expect(select_nationality_options).to include(
        SelectOptionsHelper::Option.new(nationality, nationality),
      )
    end

    it 'excludes Irish and British nationalities by default' do
      NATIONALITIES.select { |code, _| %w[GB IE].include?(code) }.each_value do |nationality|
        expect(select_nationality_options).not_to include(
          SelectOptionsHelper::Option.new(nationality, nationality),
        )
      end
    end

    it 'includes Irish and British nationalities when `include_british_and_irish` option is true' do
      NATIONALITIES.select { |code, _| %w[GB IE].include?(code) }.each_value do |nationality|
        expect(select_nationality_options(include_british_and_irish: true)).to include(
          SelectOptionsHelper::Option.new(nationality, nationality),
        )
      end
    end
  end

  describe '#select_country_options' do
    it 'returns a structured list of countries' do
      expect(select_country_options).to include(
        SelectOptionsHelper::Option.new('', t('application_form.contact_details.country.default_option')),
      )
      expect(select_country_options).to include(
        SelectOptionsHelper::Option.new('FR', 'France'),
      )
      expect(select_country_options).not_to include(
        SelectOptionsHelper::Option.new('GB', 'United Kingdom'),
      )
    end
  end
end
