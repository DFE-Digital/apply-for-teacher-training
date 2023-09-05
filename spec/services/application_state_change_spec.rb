require 'rails_helper'

RSpec.describe ApplicationStateChange do
  context 'when the interview flag is active' do
    describe '.valid_states' do
      it 'has human readable translations' do
        expect(described_class.valid_states)
          .to match_array(I18n.t('application_states').keys)

        expect(described_class.valid_states)
          .to match_array(I18n.t('candidate_application_states').keys)

        expect(described_class.valid_states)
          .to match_array(I18n.t('provider_application_states').keys)
      end

      it 'has corresponding entries in the ApplicationChoice#status enum' do
        expect(described_class.valid_states)
          .to match_array(ApplicationChoice.statuses.keys.map(&:to_sym))
      end
    end

    describe '.states_visible_to_provider' do
      it 'matches the valid states and states not visible' do
        expect(described_class.states_visible_to_provider)
          .to match_array(described_class.valid_states - described_class::STATES_NOT_VISIBLE_TO_PROVIDER)
      end
    end
  end

  describe '.states_visible_to_provider_without_deferred' do
    it 'has corresponding entries in the OpenAPI spec - excluding the interview state' do
      valid_states_in_openapi = VendorAPISpecification.new.as_hash['components']['schemas']['ApplicationAttributes']['properties']['status']['enum']

      expect(described_class.states_visible_to_provider_without_deferred - %i[interviewing offer_withdrawn inactive])
        .to match_array(valid_states_in_openapi.map(&:to_sym) - %i[offer_deferred])
    end
  end

  describe '::STATES_NOT_VISIBLE_TO_PROVIDER' do
    it 'contains the correct states to filter by' do
      expect(described_class.valid_states).to include(*described_class::STATES_NOT_VISIBLE_TO_PROVIDER)
    end
  end

  describe '.persist_workflow_state' do
    before do
      TestSuiteTimeMachine.unfreeze!
    end

    it 'updates the candidates `candidate_api_updated_at` when the state changes' do
      application_form = create(:completed_application_form)
      application_choice = create(:application_choice, :awaiting_provider_decision, application_form:)

      expect { described_class.new(application_choice).reject! }
        .to(change { application_choice.candidate.candidate_api_updated_at })
    end

    it 'does not update the candidates `candidate_api_updated_at` when state does not change' do
      application_form = create(:completed_application_form)
      application_choice = create(:application_choice, :awaiting_provider_decision, application_form:)
      create(:application_choice, :awaiting_provider_decision, application_form:)

      expect { described_class.new(application_choice).reject! }
        .not_to(change { application_choice.candidate.candidate_api_updated_at })
    end
  end
end
