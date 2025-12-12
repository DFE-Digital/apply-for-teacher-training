require 'rails_helper'

RSpec.describe SelectOptionsHelper do
  let(:non_british_codes_and_nationalities) do
    CODES_AND_NATIONALITIES.except('GB', 'GB-WLS', 'GB-CYM', 'GB-SCT', 'GB-NIR', 'GB-ENG', 'IE')
  end

  describe '#select_nationality_options' do
    it 'returns a structured list of all non-British and Irish nationalities' do
      expect(select_nationality_options).to include(
        SelectOptionsHelper::Option.new('', t('application_form.personal_details.nationality.default_option')),
      )
      non_british_codes_and_nationalities.each_value do |nationality|
        expect(select_nationality_options).to include(
          SelectOptionsHelper::Option.new(nationality, nationality),
        )
      end
    end

    it 'excludes Irish and British nationalities by default' do
      CODES_AND_NATIONALITIES.map(&:second).select { |code| %w[GB IE].include?(code) }.each do |nationality|
        expect(select_nationality_options).not_to include(
          SelectOptionsHelper::Option.new(nationality, nationality),
        )
      end
    end

    it 'includes Irish and British nationalities when `include_british_and_irish` option is true' do
      CODES_AND_NATIONALITIES.map(&:second).select { |code| %w[GB IE].include?(code) }.each do |nationality|
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
