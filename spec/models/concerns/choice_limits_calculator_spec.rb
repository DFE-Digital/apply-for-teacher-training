require 'rails_helper'

RSpec.describe ChoiceLimitsCalculator do
  describe '#limits' do
    it 'the cap is applied to all applications' do
      previously_submitted_limits = create(:application_form, submitted_at: 1.day.ago).limits
      future_submitted_new_limits = create(:application_form, submitted_at: 1.day.from_now).limits
      unsubmitted_new_limits = create(:application_form, :unsubmitted).limits

      expect(previously_submitted_limits.to_h)
        .to match({ total_application_limit: 15, in_progress_limit: 4 })
      expect(unsubmitted_new_limits.to_h)
        .to match({ total_application_limit: 15, in_progress_limit: 4 })
      expect(future_submitted_new_limits.to_h)
        .to match({ total_application_limit: 15, in_progress_limit: 4 })
    end

    describe '#unsuccessful_retry_limit' do
      let(:application_form) { create(:application_form) }

      it 'returns the total_application_limit' do
        expect(application_form.unsuccessful_retry_limit).to eq(
          application_form.total_application_limit,
        )
      end
    end
  end

  describe '#cannot_submit_more_choices?' do
    it 'only allows 15 unsuccessful applications' do
      application_form = create(:application_form)
      create_list(:application_choice, 14, :withdrawn, application_form:)
      expect(application_form.reload.cannot_submit_more_choices?).to be false

      create(:application_choice, :withdrawn, application_form:)
      expect(application_form.reload.cannot_submit_more_choices?).to be true
    end

    it 'only allows 4 in progress applications' do
      application_form = create(:application_form)
      create_list(:application_choice, 3, :awaiting_provider_decision, application_form:)
      expect(application_form.reload.cannot_submit_more_choices?).to be false

      create(:application_choice, :awaiting_provider_decision, application_form:)
      expect(application_form.reload.cannot_submit_more_choices?).to be true
    end

    it 'only allows 19 total submitted applications, regardless of state' do
      application_form = create(:application_form)
      create_list(:application_choice, 3, :awaiting_provider_decision, application_form:)
      create_list(:application_choice, 14, :rejected, application_form:)
      expect(application_form.reload.cannot_submit_more_choices?).to be false

      create_list(:application_choice, 2, :rejected, application_form:)
      expect(application_form.reload.cannot_submit_more_choices?).to be true
    end

    context 'when the application if after the 2026 recruitment cycle' do
      it 'only allows 15 total submitted applications, regardless of state' do
        application_form = create(:application_form, recruitment_cycle_year: 2027)
        create_list(:application_choice, 3, :awaiting_provider_decision, application_form:, current_recruitment_cycle_year: 2027)
        create_list(:application_choice, 10, :rejected, application_form:, current_recruitment_cycle_year: 2027)
        expect(application_form.reload.cannot_submit_more_choices?).to be false

        create_list(:application_choice, 2, :rejected, application_form:)
        expect(application_form.reload.cannot_submit_more_choices?).to be true
      end
    end
  end

  describe '#number_of_slots_left' do
    it 'only allows 4 draft slots' do
      application_form = create(:application_form)
      create_list(:application_choice, 3, :unsubmitted, application_form:)
      expect(application_form.reload.number_of_slots_left).to eq 1

      create(:application_choice, :unsubmitted, application_form:)
      expect(application_form.reload.number_of_slots_left).to eq 0
    end

    it 'only allows 4 in progress slots' do
      application_form = create(:application_form)
      create_list(:application_choice, 3, :awaiting_provider_decision, application_form:)
      expect(application_form.reload.number_of_slots_left).to eq 1

      create(:application_choice, :interviewing, application_form:)
      expect(application_form.reload.number_of_slots_left).to eq 0
    end

    it 'allows 15 unsuccessful before reducing slots' do
      application_form = create(:application_form)
      create_list(:application_choice, 15, :withdrawn, application_form:)
      expect(application_form.reload.number_of_slots_left).to eq 4

      create(:application_choice, :rejected, application_form:)
      expect(application_form.reload.number_of_slots_left).to eq 3
    end

    context 'when the application if after the 2026 recruitment cycle' do
      it 'reduces the number of slots dependant on the number of maximum applications' do
        application_form = create(:application_form, recruitment_cycle_year: 2027)
        create_list(:application_choice, 11, :withdrawn, application_form:, current_recruitment_cycle_year: 2027)
        expect(application_form.reload.number_of_slots_left).to eq 4

        create(:application_choice, :rejected, application_form:, current_recruitment_cycle_year: 2027)
        expect(application_form.reload.number_of_slots_left).to eq 3

        create(:application_choice, :rejected, application_form:, current_recruitment_cycle_year: 2027)
        expect(application_form.reload.number_of_slots_left).to eq 2

        create(:application_choice, :rejected, application_form:, current_recruitment_cycle_year: 2027)
        expect(application_form.reload.number_of_slots_left).to eq 1

        create(:application_choice, :rejected, application_form:, current_recruitment_cycle_year: 2027)
        expect(application_form.reload.number_of_slots_left).to eq 0
      end
    end

    it 'only allows more choices if the total of 4 slots in progress and draft' do
      application_form = create(:application_form)
      create_list(:application_choice, 2, :awaiting_provider_decision, application_form:)
      create(:application_choice, :interviewing, application_form:)
      expect(application_form.reload.number_of_slots_left).to eq 1

      create(:application_choice, :unsubmitted, application_form:)
      expect(application_form.reload.number_of_slots_left).to eq 0
    end
  end
end
