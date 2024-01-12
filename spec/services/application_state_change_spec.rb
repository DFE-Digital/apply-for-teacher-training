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
  end

  describe '.states_by_category' do
    it 'has all states in the correct categories' do
      expect(described_class.states_by_category).to include(
        not_visible_to_provider: %i[unsubmitted cancelled application_not_sent],
        visible_to_provider: %i[awaiting_provider_decision conditions_not_met declined inactive interviewing offer offer_deferred offer_withdrawn pending_conditions recruited rejected withdrawn],
        interviewable: %i[awaiting_provider_decision interviewing],
        accepted: %i[conditions_not_met offer_deferred pending_conditions recruited],
        offered: %i[conditions_not_met declined offer offer_deferred offer_withdrawn pending_conditions recruited],
        post_offered: %i[conditions_not_met declined declined offer_deferred offer_withdrawn offer_withdrawn pending_conditions recruited],
        unsuccessful: %i[withdrawn cancelled rejected declined conditions_not_met offer_withdrawn application_not_sent inactive],
        successful: %i[offer offer_deferred pending_conditions recruited],
        decision_pending: %i[awaiting_provider_decision interviewing],
        decision_pending_and_inactive: %i[awaiting_provider_decision inactive interviewing],
        reapply: %i[cancelled declined offer_withdrawn rejected withdrawn],
        terminal: %i[application_not_sent cancelled conditions_not_met declined inactive offer_withdrawn recruited rejected withdrawn],
        in_progress: %i[awaiting_provider_decision interviewing conditions_not_met offer_deferred pending_conditions recruited offer],
      )
    end
  end

  describe '.categories_by_state' do
    it 'accounts for all valid states' do
      expect(described_class.categories_by_state.keys)
        .to match_array(described_class.valid_states)
    end
  end

  describe 'states by category' do
    describe '.visible_to_provider' do
      it 'matches the valid states and states not visible' do
        expect(described_class.visible_to_provider).to eq(described_class::STATES_BY_CATEGORY[:visible_to_provider])
      end
    end

    describe '.not_visible_to_provider' do
      it 'matches the valid states and states not visible' do
        expect(described_class.not_visible_to_provider).to eq(described_class::STATES_BY_CATEGORY[:not_visible_to_provider])
      end
    end

    describe '.interviewable' do
      it 'matches the valid states and states not visible' do
        expect(described_class.interviewable).to eq(described_class::STATES_BY_CATEGORY[:interviewable])
      end
    end

    describe '.accepted' do
      it 'matches the valid states and states not visible' do
        expect(described_class.accepted).to eq(described_class::STATES_BY_CATEGORY[:accepted])
      end
    end

    describe '.offered' do
      it 'matches the valid states and states not visible' do
        expect(described_class.offered).to eq(described_class::STATES_BY_CATEGORY[:offered])
      end
    end

    describe '.post_offered' do
      it 'matches the valid states and states not visible' do
        expect(described_class.post_offered).to eq(described_class::STATES_BY_CATEGORY[:post_offered])
      end
    end

    describe '.unsuccessful' do
      it 'matches the valid states and states not visible' do
        expect(described_class.unsuccessful).to eq(described_class::STATES_BY_CATEGORY[:unsuccessful])
      end
    end

    describe '.successful' do
      it 'matches the valid states and states not visible' do
        expect(described_class.successful).to eq(described_class::STATES_BY_CATEGORY[:successful])
      end
    end

    describe '.decision_pending' do
      it 'matches the valid states and states not visible' do
        expect(described_class.decision_pending).to eq(described_class::STATES_BY_CATEGORY[:decision_pending])
      end
    end

    describe '.decision_pending_and_inactive' do
      it 'matches the valid states and states not visible' do
        expect(described_class.decision_pending_and_inactive).to eq(described_class::STATES_BY_CATEGORY[:decision_pending_and_inactive])
      end
    end

    describe '.terminal' do
      it 'matches the valid states and states not visible' do
        expect(described_class.terminal).to eq(described_class::STATES_BY_CATEGORY[:terminal])
      end
    end

    describe '.in_progress' do
      it 'matches the valid states and states not visible' do
        expect(described_class.in_progress).to eq(described_class::STATES_BY_CATEGORY[:in_progress])
      end
    end
  end

  describe '.visible_to_provider' do
    it 'matches the valid states and states not visible' do
      expect(described_class.visible_to_provider)
        .to match_array(described_class.valid_states - described_class.not_visible_to_provider)
    end
  end

  describe '.states_visible_to_provider_without_deferred' do
    it 'has corresponding entries in the OpenAPI spec - excluding the interview state' do
      valid_states_in_openapi = VendorAPISpecification.new.as_hash['components']['schemas']['ApplicationAttributes']['properties']['status']['enum']

      expect(described_class.states_visible_to_provider_without_deferred - %i[interviewing offer_withdrawn inactive])
        .to match_array(valid_states_in_openapi.map(&:to_sym) - %i[offer_deferred])
    end
  end

  describe '.not_visible_to_provider' do
    it 'contains the correct states to filter by' do
      expect(described_class.valid_states).to include(*described_class.not_visible_to_provider)
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
