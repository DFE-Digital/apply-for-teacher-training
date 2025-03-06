require 'rails_helper'

RSpec.describe Pool::Candidates do
  describe '.application_forms_for_provider' do
    context 'tests base query without filters' do
      it 'returns application_forms that should be on candidate pool list' do
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

        application_forms = described_class.application_forms_for_provider(providers:, filters: {})

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
        application_forms = described_class.application_forms_for_provider(providers:, filters: {})

        expect(application_forms).to be_empty
      end
    end

    context 'with filters' do
      it 'returns application_forms based on filters' do
        providers = [create(:provider)]

        manchester_candidate = create(:candidate, pool_status: 'opt_in')
        manchester_candidate_form = create(:application_form, :completed, candidate: manchester_candidate)
        aa_teamworks = create(
          :site,
          latitude: 51.4524877,
          longitude: -0.1204749,
          provider: providers.first,
        )
        course_option = create(
          :course_option,
          site: aa_teamworks,
          course: create(:course, provider: providers.first),
        )
        create(:application_choice, :rejected, application_form: manchester_candidate_form, course_option:)

        visa_sponsorship_candidate = create(:candidate, pool_status: 'opt_in')
        visa_sponsorship_candidate_form = create(
          :application_form,
          :completed,
          candidate: visa_sponsorship_candidate,
          right_to_work_or_study: :no,
        )
        aa_teamworks = create(
          :site,
          latitude: 51.4524893,
          longitude: -0.1204768,
          provider: providers.first,
        )
        course_option = create(
          :course_option,
          site: aa_teamworks,
          course: create(:course, provider: providers.first),
        )
        create(:application_choice, :declined, application_form: visa_sponsorship_candidate_form, course_option:)

        withdrawn_candidate = create(:candidate, pool_status: 'opt_in')
        withdrawn_candidate_form = create(:application_form, :completed, candidate: withdrawn_candidate)
        create(:application_choice, :withdrawn, application_form: withdrawn_candidate_form)

        filters = { origin: [51.4524877, -0.1204749], within: 10 }
        application_forms = described_class.application_forms_for_provider(providers:, filters:)

        expect(application_forms).to contain_exactly(
          manchester_candidate_form,
          visa_sponsorship_candidate_form,
        )

        filters = {
          origin: [51.4524877, -0.1204749],
          within: 10,
          visa_sponsorship: ['required'],
        }

        application_forms = described_class.application_forms_for_provider(providers:, filters:)

        expect(application_forms).to contain_exactly(
          visa_sponsorship_candidate_form,
        )
      end
    end
  end
end
