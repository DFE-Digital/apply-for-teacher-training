require 'rails_helper'

RSpec.describe GetRefereesToChase do
  describe '#call' do
    context 'when between apply 1 deadline and find has opened' do
      around do |example|
        Timecop.travel(CycleTimetable.apply_1_deadline(2022) + 1.day) { example.run }
      end

      it 'returns requested references for candidates on apply 2 only for the current cycle' do
        application_form = create(:application_form, :minimum_info, recruitment_cycle_year: 2022)
        create(:reference, :feedback_requested, application_form: application_form, requested_at: CycleTimetable.apply_1_deadline - 7.days)

        application_form_apply_again = create(:application_form, :minimum_info, recruitment_cycle_year: 2022, phase: 'apply_2')
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

    context 'when between apply has opened and the apply 1 deadline' do
      around do |example|
        Timecop.travel(CycleTimetable.find_reopens(2023) + 7.days) { example.run }
      end

      it 'returns requested references in last days of current recruiment cycle' do
        old_application_form = create(:application_form, :minimum_info, recruitment_cycle_year: 2022, phase: 'apply_1')
        create(:reference, :feedback_requested, application_form: old_application_form, requested_at: CycleTimetable.find_reopens(2023) - 7.days)

        old_application_form_apply_again = create(:application_form, :minimum_info, recruitment_cycle_year: 2022, phase: 'apply_2')
        create(:reference, :feedback_requested, application_form: old_application_form_apply_again, requested_at: CycleTimetable.find_reopens(2023) - 7.days)

        application_form = create(:application_form, :minimum_info, recruitment_cycle_year: 2023)
        reference = create(:reference, :feedback_requested, application_form: application_form, requested_at: CycleTimetable.find_reopens(2023))

        references = described_class.new(
          chase_referee_by: 7.days.before(Time.zone.now),
          rejected_chased_ids: [],
        ).call
        expect(references).to match_array([reference])
      end
    end
  end
end
