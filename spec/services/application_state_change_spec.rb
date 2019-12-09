require 'rails_helper'

RSpec.describe ApplicationStateChange do
  describe '.valid_states' do
    it 'has human readable translations' do
      expect(ApplicationStateChange.valid_states)
        .to match_array(I18n.t('support_application_states').keys)

      expect(ApplicationStateChange.valid_states)
        .to match_array(I18n.t('candidate_application_states').keys)

      expect(ApplicationStateChange.valid_states)
        .to match_array(I18n.t('provider_application_states').keys)
    end

    it 'has corresponding entries in the ApplicationChoice#status enum' do
      expect(ApplicationStateChange.valid_states)
        .to match_array(ApplicationChoice.statuses.keys.map(&:to_sym))
    end
  end

  describe '.states_visible_to_provider' do
    it 'has corresponding entries in the OpenAPI spec' do
      valid_states_in_openapi = YAML.load_file('config/vendor-api-0.8.0.yml')['components']['schemas']['ApplicationAttributes']['properties']['status']['enum']

      expect(ApplicationStateChange.states_visible_to_provider)
        .to match_array(valid_states_in_openapi.map(&:to_sym))
    end
  end

  describe '.states_not_visible_to_provider' do
    it 'contains the correct states to filter by' do
      expect(ApplicationStateChange.valid_states).to include(*ApplicationStateChange.states_not_visible_to_provider)
    end
  end
end
