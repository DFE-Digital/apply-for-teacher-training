require 'rails_helper'

RSpec.describe Pool::Candidates do
  describe '.for_provider' do
    it 'returns candidates that should be on candidate pool list' do
      providers = [create(:provider)]

      rejected_candidate = create(:candidate, pool_status: 'opt_in')
      rejected_candidate_form = create(:application_form, :completed, candidate: rejected_candidate)
      create(:application_choice, :rejected, application_form: rejected_candidate_form)

      declined_candidate = create(:candidate, pool_status: 'opt_in')
      declined_candidate_form = create(:application_form, :completed, candidate: declined_candidate)
      create(:application_choice, :declined, application_form: declined_candidate_form)

      withdrawn_candidate = create(:candidate, pool_status: 'opt_in')
      withdrawn_candidate_form = create(:application_form, :completed, candidate: withdrawn_candidate)
      create(:application_choice, :withdrawn, application_form: withdrawn_candidate_form)

      conditions_not_met_candidate = create(:candidate, pool_status: 'opt_in')
      conditions_not_met_candidate_form = create(:application_form, :completed, candidate: conditions_not_met_candidate)
      create(:application_choice, :conditions_not_met, application_form: conditions_not_met_candidate_form)

      offer_withdrawn_candidate = create(:candidate, pool_status: 'opt_in')
      offer_withdrawn_candidate_form = create(:application_form, :completed, candidate: offer_withdrawn_candidate)
      create(:application_choice, :offer_withdrawn, application_form: offer_withdrawn_candidate_form)

      inactive_candidate = create(:candidate, pool_status: 'opt_in')
      inactive_candidate_form = create(:application_form, :completed, candidate: inactive_candidate)
      create(:application_choice, :inactive, application_form: inactive_candidate_form)

      candidates = described_class.for_provider(providers:)

      expect(candidates).to contain_exactly(
        rejected_candidate,
        declined_candidate,
        withdrawn_candidate,
        conditions_not_met_candidate,
        offer_withdrawn_candidate,
        inactive_candidate,
      )
    end

    it 'does not returns candidates that should not be on the candidate pool list' do
      provider = create(:provider)
      providers = [provider]

      opt_out_candidate = create(:candidate, pool_status: 'opt_out')
      opt_out_candidate_form = create(:application_form, :completed, candidate: opt_out_candidate)
      create(:application_choice, :rejected, application_form: opt_out_candidate_form)

      dismissed_candidate = create(:candidate, pool_status: 'opt_in')
      dismissed_candidate_form = create(:application_form, :completed, candidate: dismissed_candidate)
      create(:application_choice, :rejected, application_form: dismissed_candidate_form)
      create(:pool_dismissal, provider:, candidate: dismissed_candidate)

      rejected_candidate = create(:candidate, pool_status: 'opt_in')
      rejected_candidate_form = create(:application_form, :completed, candidate: rejected_candidate)
      create(:application_choice, :rejected, application_form: rejected_candidate_form)
      create(:application_choice, :awaiting_provider_decision, application_form: rejected_candidate_form)

      declined_candidate = create(:candidate, pool_status: 'opt_in')
      declined_candidate_form = create(:application_form, :completed, candidate: declined_candidate)
      create(:application_choice, :declined, application_form: declined_candidate_form)
      create(:application_choice, :interviewing, application_form: declined_candidate_form)

      withdrawn_candidate = create(:candidate, pool_status: 'opt_in')
      withdrawn_candidate_form = create(:application_form, :completed, candidate: withdrawn_candidate)
      create(:application_choice, :withdrawn, application_form: withdrawn_candidate_form)
      create(:application_choice, :offer, application_form: withdrawn_candidate_form)

      conditions_not_met_candidate = create(:candidate, pool_status: 'opt_in')
      conditions_not_met_candidate_form = create(:application_form, :completed, candidate: conditions_not_met_candidate)
      create(:application_choice, :conditions_not_met, application_form: conditions_not_met_candidate_form)
      create(:application_choice, :pending_conditions, application_form: conditions_not_met_candidate_form)

      offer_withdrawn_candidate = create(:candidate, pool_status: 'opt_in')
      offer_withdrawn_candidate_form = create(:application_form, :completed, candidate: offer_withdrawn_candidate)
      create(:application_choice, :offer_withdrawn, application_form: offer_withdrawn_candidate_form)
      create(:application_choice, :recruited, application_form: offer_withdrawn_candidate_form)

      inactive_candidate = create(:candidate, pool_status: 'opt_in')
      inactive_candidate_form = create(:application_form, :completed, candidate: inactive_candidate)
      create(:application_choice, :inactive, application_form: inactive_candidate_form)
      create(:application_choice, :offer_deferred, application_form: inactive_candidate_form)
      candidates = described_class.for_provider(providers:)

      expect(candidates).to be_empty
    end
  end
end
