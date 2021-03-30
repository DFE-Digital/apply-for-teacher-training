require 'rails_helper'

RSpec.describe ApplicationStateChange do
  context 'when the interview flag is active' do
    before do
      FeatureFlag.activate(:interviews)
    end

    describe '.valid_states' do
      it 'has human readable translations' do
        expect(ApplicationStateChange.valid_states)
          .to match_array(I18n.t('application_states').keys)

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
      it 'matches the valid states and states not visible' do
        expect(ApplicationStateChange.states_visible_to_provider)
          .to match_array(ApplicationStateChange.valid_states - ApplicationStateChange::STATES_NOT_VISIBLE_TO_PROVIDER)
      end
    end
  end

  context 'when the interview flag is inactive' do
    before do
      FeatureFlag.deactivate(:interviews)
    end

    describe '.valid_states' do
      it 'has human readable translations' do
        expect(ApplicationStateChange.valid_states)
          .to match_array(I18n.t('application_states').keys - %i[interviewing])

        expect(ApplicationStateChange.valid_states)
          .to match_array(I18n.t('candidate_application_states').keys - %i[interviewing])

        expect(ApplicationStateChange.valid_states)
          .to match_array(I18n.t('provider_application_states').keys - %i[interviewing])
      end

      it 'has corresponding entries in the ApplicationChoice#status enum' do
        expect(ApplicationStateChange.valid_states)
          .to match_array(ApplicationChoice.statuses.keys.map(&:to_sym) - %i[interviewing])
      end
    end

    describe '.states_visible_to_provider' do
      it 'matches the valid states and states not visible' do
        expect(ApplicationStateChange.states_visible_to_provider)
          .to match_array(ApplicationStateChange.valid_states - ApplicationStateChange::STATES_NOT_VISIBLE_TO_PROVIDER - %i[interviewing])
      end
    end
  end

  describe '.states_visible_to_provider_without_deferred' do
    it 'has corresponding entries in the OpenAPI spec - excluding the interview state' do
      valid_states_in_openapi = VendorAPISpecification.as_hash['components']['schemas']['ApplicationAttributes']['properties']['status']['enum']

      expect(ApplicationStateChange.states_visible_to_provider_without_deferred - %i[interviewing offer_withdrawn])
        .to match_array(valid_states_in_openapi.map(&:to_sym))
    end
  end

  describe '::STATES_NOT_VISIBLE_TO_PROVIDER' do
    it 'contains the correct states to filter by' do
      expect(ApplicationStateChange.valid_states).to include(*ApplicationStateChange::STATES_NOT_VISIBLE_TO_PROVIDER)
    end
  end
end
