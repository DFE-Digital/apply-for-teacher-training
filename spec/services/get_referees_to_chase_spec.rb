require 'rails_helper'

RSpec.describe GetRefereesToChase do
  describe '#call' do
    context 'when application is not pending conditions recruited or offer deferred', time: (CycleTimetable.find_reopens(2023) + 10.days) do
      it 'does not return references to chase' do
        application_form = create(:application_form, :minimum_info, recruitment_cycle_year: 2023)
        create(:reference, :feedback_requested, application_form:, requested_at: 8.days.ago)
        create(:submitted_application_choice, application_form:)
        create(:application_choice, :withdrawn, application_form:)
        create(:application_choice, :with_rejection, application_form:)

        references = described_class.new(
          chase_referee_by: 7.days.before(1.second.from_now),
          rejected_chased_ids: [],
        ).call
        expect(references).to be_empty
      end
    end

    context 'when application is recruited or offer deferred' do
      it 'returns references to chase' do
        application_form = create(:application_form, :minimum_info, recruitment_cycle_year: 2023)
        reference = create(:reference, :feedback_requested, application_form:, requested_at: 8.days.ago)
        create(:application_choice, :with_recruited, application_form:)
        create(:application_choice, :withdrawn, application_form:)

        second_application_form = create(:application_form, :minimum_info, recruitment_cycle_year: 2023)
        second_application_form_reference = create(:reference, :feedback_requested, application_form: second_application_form, requested_at: 8.days.ago)
        create(:application_choice, :offer_deferred, application_form: second_application_form)
        create(:application_choice, :withdrawn, application_form: second_application_form)

        references = described_class.new(
          chase_referee_by: 7.days.before(1.second.from_now),
          rejected_chased_ids: [],
        ).call
        expect(references).to include(reference, second_application_form_reference)
      end
    end

    context 'when between apply 1 deadline and find has opened', time: (CycleTimetable.apply_1_deadline(2022) + 1.day) do
      it 'returns requested references for candidates on apply 2 only for the current cycle' do
        application_form = create(:application_form, :minimum_info, recruitment_cycle_year: 2022)
        create(:reference, :feedback_requested, application_form: application_form, requested_at: CycleTimetable.apply_1_deadline - 7.days)

        application_form_apply_again = create(:application_form, :minimum_info, recruitment_cycle_year: 2022, phase: 'apply_2')
        create(:application_choice, :with_accepted_offer, application_form: application_form_apply_again)
        first_reference_apply_again = create(:reference, :feedback_requested, application_form: application_form_apply_again, requested_at: 8.days.ago)
        second_reference_apply_again = create(:reference, :feedback_requested, application_form: application_form_apply_again, requested_at: 8.days.ago)

        application_form_next_cycle =  create(:application_form, :minimum_info, recruitment_cycle_year: 2023)
        create(:reference, :feedback_requested, application_form: application_form_next_cycle, requested_at: CycleTimetable.apply_1_deadline - 7.days)

        references = described_class.new(
          chase_referee_by: 7.days.before(Time.zone.now),
          rejected_chased_ids: [second_reference_apply_again.id],
        ).call

        expect(references).to match_array([first_reference_apply_again])
      end
    end

    context 'when between apply has opened and the apply 1 deadline', time: (CycleTimetable.find_reopens(2023) + 7.days) do
      it 'returns requested references in last days of current recruiment cycle' do
        old_application_form = create(:application_form, :minimum_info, recruitment_cycle_year: 2022, phase: 'apply_1')
        create(:reference, :feedback_requested, application_form: old_application_form, requested_at: CycleTimetable.find_reopens(2023) - 7.days)

        old_application_form_apply_again = create(:application_form, :minimum_info, recruitment_cycle_year: 2022, phase: 'apply_2')
        create(:application_choice, :with_accepted_offer, application_form: old_application_form_apply_again)
        create(:reference, :feedback_requested, application_form: old_application_form_apply_again, requested_at: CycleTimetable.find_reopens(2023) - 7.days)

        application_form = create(:application_form, :minimum_info, recruitment_cycle_year: 2023)
        create(:application_choice, :with_accepted_offer, application_form:)
        reference = create(:reference, :feedback_requested, application_form: application_form, requested_at: CycleTimetable.find_reopens(2023))

        references = described_class.new(
          chase_referee_by: 7.days.before(1.second.from_now),
          rejected_chased_ids: [],
        ).call
        expect(references).to match_array([reference])
      end
    end
  end
end
