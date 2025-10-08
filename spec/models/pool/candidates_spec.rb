require 'rails_helper'

RSpec.describe Pool::Candidates do
  describe '.application_forms_for_provider' do
    context 'tests base query without filters' do
      it 'returns application_forms that should be on candidate pool list' do
        application_in_the_pool = create(:application_form)
        create(:candidate_pool_application, application_form: application_in_the_pool)
        _application_not_in_the_pool = create(:application_form)

        application_forms = described_class.application_forms_for_provider(filters: {})

        expect(application_forms).to contain_exactly(
          application_in_the_pool,
        )
      end
    end

    context 'with filters' do
      it 'returns application_forms based on filters' do
        manchester_coordinates = [53.4807593, -2.2426305]

        manchester_application = create(:application_form, :completed)
        create(
          :candidate_pool_application,
          application_form: manchester_application,
        )
        manchester_preference = create(:candidate_preference, application_form: manchester_application)
        create(:candidate_location_preference, :manchester, candidate_preference: manchester_preference)

        liverpool_application = create(:application_form, :completed)
        create(
          :candidate_pool_application,
          application_form: liverpool_application,
        )
        liverpool_preference = create(:candidate_preference, application_form: liverpool_application)
        create(:candidate_location_preference, :liverpool, candidate_preference: liverpool_preference)

        anywhere_application = create(:application_form, :completed)
        create(:candidate_pool_application, application_form: anywhere_application)
        create(:candidate_preference, :anywhere_in_england, application_form: anywhere_application)

        filters = {}
        application_forms = described_class.application_forms_for_provider(filters:)

        expect(application_forms.map(&:id)).to contain_exactly(
          anywhere_application.id,
          manchester_application.id,
          liverpool_application.id,
        )

        filters = { origin: manchester_coordinates }
        application_forms = described_class.application_forms_for_provider(filters:)

        expect(application_forms.map(&:id)).to contain_exactly(
          anywhere_application.id,
          manchester_application.id,
        )
      end
    end
  end

  describe '#application_forms_in_the_pool' do
    it 'returns application_forms that should be in the candidate pool' do
      rejected_candidate_form = create(:application_form, :completed)
      create(:candidate_preference, application_form: rejected_candidate_form)
      create(:application_choice, :rejected, application_form: rejected_candidate_form)

      declined_candidate_form = create(:application_form, :completed)
      create(:candidate_preference, application_form: declined_candidate_form)
      create(:application_choice, :declined, application_form: declined_candidate_form)

      withdrawn_candidate_form = create(:application_form, :completed)
      create(:candidate_preference, application_form: withdrawn_candidate_form)
      create(:application_choice, :withdrawn, application_form: withdrawn_candidate_form)

      conditions_not_met_candidate_form = create(:application_form, :completed)
      create(:candidate_preference, application_form: conditions_not_met_candidate_form)
      create(:application_choice, :conditions_not_met, application_form: conditions_not_met_candidate_form)

      offer_withdrawn_candidate_form = create(:application_form, :completed)
      create(:candidate_preference, application_form: offer_withdrawn_candidate_form)
      create(:application_choice, :offer_withdrawn, application_form: offer_withdrawn_candidate_form)

      inactive_candidate_form = create(:application_form, :completed)
      create(:candidate_preference, application_form: inactive_candidate_form)
      create(:application_choice, :inactive, application_form: inactive_candidate_form)

      application_forms = described_class.new.application_forms_in_the_pool

      expect(application_forms).to contain_exactly(
        rejected_candidate_form,
        declined_candidate_form,
        withdrawn_candidate_form,
        conditions_not_met_candidate_form,
        offer_withdrawn_candidate_form,
        inactive_candidate_form,
      )
    end

    it 'does not returns application_forms that should not be on the candidate pool list' do
      previous_year_form = create(:application_form, :completed, recruitment_cycle_year: previous_year)
      create(:candidate_preference, application_form: previous_year_form)
      create(:application_choice, :rejected, application_form: previous_year_form)

      # opt_out_candidate = create(:candidate)
      opt_out_candidate_form = create(:application_form, :completed)
      create(:candidate_preference, pool_status: 'opt_out', application_form: opt_out_candidate_form)
      create(:application_choice, :rejected, application_form: opt_out_candidate_form)

      rejected_candidate_form = create(:application_form, :completed)
      create(:candidate_preference, application_form: rejected_candidate_form)
      create(:application_choice, :rejected, application_form: rejected_candidate_form)
      create(:application_choice, :awaiting_provider_decision, application_form: rejected_candidate_form)

      declined_candidate_form = create(:application_form)
      create(:candidate_preference, application_form: declined_candidate_form)
      create(:application_choice, :declined, application_form: declined_candidate_form)
      create(:application_choice, :interviewing, application_form: declined_candidate_form)

      withdrawn_candidate_form = create(:application_form, :completed)
      create(:candidate_preference, application_form: withdrawn_candidate_form)
      create(:application_choice, :withdrawn, application_form: withdrawn_candidate_form)
      create(:application_choice, :offer, application_form: withdrawn_candidate_form)

      conditions_not_met_candidate_form = create(:application_form, :completed)
      create(:candidate_preference, application_form: conditions_not_met_candidate_form)
      create(:application_choice, :conditions_not_met, application_form: conditions_not_met_candidate_form)
      create(:application_choice, :pending_conditions, application_form: conditions_not_met_candidate_form)

      offer_withdrawn_candidate_form = create(:application_form, :completed)
      create(:candidate_preference, application_form: offer_withdrawn_candidate_form)
      create(:application_choice, :offer_withdrawn, application_form: offer_withdrawn_candidate_form)
      create(:application_choice, :recruited, application_form: offer_withdrawn_candidate_form)

      inactive_candidate_form = create(:application_form, :completed)
      create(:candidate_preference, application_form: inactive_candidate_form)
      create(:application_choice, :inactive, application_form: inactive_candidate_form)
      create(:application_choice, :offer_deferred, application_form: inactive_candidate_form)

      candidate_with_too_many_choices_form = create(:application_form, :completed)
      create(:candidate_preference, application_form: candidate_with_too_many_choices_form)
      create_list(:application_choice, 15, :offer_withdrawn, application_form: candidate_with_too_many_choices_form)

      withdrawn_no_longer_wants_to_train_form = create(
        :application_form,
        :completed,
      )
      create(:candidate_preference, application_form: withdrawn_no_longer_wants_to_train_form)
      withdrawn_choice = create(
        :application_choice,
        :withdrawn,
        application_form: withdrawn_no_longer_wants_to_train_form,
      )
      create(
        :withdrawal_reason,
        application_choice: withdrawn_choice,
        reason: 'do-not-want-to-train-anymore.personal-circumstances-have-changed',
      )

      application_form_declined_invites_no_longer_wants_to_train = create(:application_form, :completed)
      create(:candidate_preference, application_form: application_form_declined_invites_no_longer_wants_to_train)
      create(:application_choice, :rejected, application_form: application_form_declined_invites_no_longer_wants_to_train)
      pool_invite_declined_invites_no_longer_wants_to_train = create(:pool_invite,
                                                                     :sent_to_candidate,
                                                                     application_form: application_form_declined_invites_no_longer_wants_to_train,
                                                                     candidate_decision: :declined)
      create(:pool_invite_decline_reason, invite: pool_invite_declined_invites_no_longer_wants_to_train, reason: 'no_longer_interested')

      application_forms = described_class.new.application_forms_in_the_pool

      expect(application_forms).to be_empty
    end
  end
end
