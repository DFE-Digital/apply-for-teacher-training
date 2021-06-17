require 'rails_helper'

RSpec.describe ProviderInterface::SortApplicationChoices do
  around do |example|
    Timecop.travel(2021, 1, 1) { example.run }
  end

  describe 'decorates models with' do
    let(:model) do
      create(:application_choice, :awaiting_provider_decision)
      described_class.call(application_choices: ApplicationChoice.all).first
    end

    it 'task_view_group' do
      expect(model).to respond_to(:task_view_group)
    end

    it 'pg_days_left_to_respond' do
      expect(model).to respond_to(:pg_days_left_to_respond)
    end
  end

  describe 'pg_days_left_to_respond' do
    let(:pg_days_left_to_respond) do
      described_class.call(application_choices: ApplicationChoice.all).first.pg_days_left_to_respond
    end

    it 'is nil when reject_by_default_at is in the past' do
      create(:application_choice, :awaiting_provider_decision, reject_by_default_at: 1.day.ago)
      expect(pg_days_left_to_respond).to be_nil
    end

    it 'is zero when reject_by_default_at is tonight' do
      create(:application_choice, :awaiting_provider_decision, reject_by_default_at: Time.zone.now.end_of_day)
      expect(pg_days_left_to_respond).to eq(0)
    end

    it 'is the correct number of days when reject_by_default_at is in the future' do
      create(:application_choice, :awaiting_provider_decision, reject_by_default_at: 3.days.from_now.end_of_day)
      expect(pg_days_left_to_respond).to eq(3)
    end
  end

  describe 'task view groups' do
    let(:application_choice) do
      described_class.call(application_choices: ApplicationChoice.all).first
    end

    it '#deferred_offers_pending_reconfirmation' do
      create(:application_choice, :with_deferred_offer, :previous_year)
      expect(application_choice.task_view_group).to eq(1)
    end

    describe '#about_to_be_rejected_automatically' do
      it '.awaiting_provider_decision' do
        create(:application_choice, :awaiting_provider_decision, reject_by_default_at: 5.business_days.after(Time.zone.now))
        expect(application_choice.task_view_group).to eq(2)
      end

      it '.interviewing' do
        create(:application_choice, :interviewing, reject_by_default_at: 5.business_days.after(Time.zone.now))
        expect(application_choice.task_view_group).to eq(2)
      end
    end

    it '#give_feedback_for_rbd' do
      create(:application_choice, :with_rejection_by_default, rejection_reason: nil, structured_rejection_reasons: nil, rejected_at: Time.zone.parse(ProviderInterface::SortApplicationChoices::RBD_FEEDBACK_LAUNCH_TIMESTAMP))
      expect(application_choice.task_view_group).to eq(3)
    end

    it '#awaiting_provider_decision_non_urgent' do
      create(:application_choice, :awaiting_provider_decision, reject_by_default_at: 6.business_days.from_now)
      expect(application_choice.task_view_group).to eq(4)
    end

    it '#interviewing_non_urgent' do
      create(:application_choice, :interviewing, reject_by_default_at: 6.business_days.from_now)
      expect(application_choice.task_view_group).to eq(5)
    end

    it '#pending_conditions_previous_cycle' do
      create(:application_choice, :pending_conditions, :previous_year)
      expect(application_choice.task_view_group).to eq(6)
    end

    it '#waiting_on_candidate' do
      create(:application_choice, :offer)
      expect(application_choice.task_view_group).to eq(7)
    end

    it '#pending_conditions_current_cycle' do
      create(:application_choice, :pending_conditions)
      expect(application_choice.task_view_group).to eq(8)
    end

    it '#successful_candidates' do
      create(:application_choice, :recruited)
      expect(application_choice.task_view_group).to eq(9)
    end

    it '#deferred_offers_current_cycle' do
      create(:application_choice, :with_deferred_offer)
      expect(application_choice.task_view_group).to eq(10)
    end

    it 'all other applications' do
      create(:application_choice, :withdrawn)
      expect(application_choice.task_view_group).to eq(999)
    end
  end

  describe 'sorts application choices' do
    let(:application_choices) do
      [
        # --- 999
        create(:application_choice, :offer, status: 'offer_withdrawn'),
        # --- 10
        create(:application_choice, :offer_deferred),
        # --- 9
        create(:application_choice, :recruited),
        # --- 8
        create(:application_choice, :pending_conditions),
        # --- 7
        create(:application_choice, :offer),
        # --- 6
        create(:application_choice, :pending_conditions, :previous_year),
        # --- 5
        create(:application_choice, :with_scheduled_interview),
        # --- 4
        create(:application_choice, :awaiting_provider_decision, reject_by_default_at: 6.business_days.from_now),
        create(:application_choice, :awaiting_provider_decision, reject_by_default_at: 6.business_days.from_now), # has more recent updated_at, will appear first
        # --- 3
        create(:application_choice, :with_rejection_by_default),
        # --- 2
        create(:application_choice, :awaiting_provider_decision, reject_by_default_at: 5.business_days.from_now),
        create(:application_choice, :awaiting_provider_decision, reject_by_default_at: 5.business_days.from_now), # has more recent updated_at, will appear first
        # --- 1
        create(:application_choice, :offer_deferred, :previous_year),
      ]
    end

    it 'according to their task_view_group, rbd and updated_at' do
      expected = application_choices.reverse
      result = described_class.call(application_choices: ApplicationChoice.all)
      expect(result).to eq(expected)
    end

    it 'includes all applications passed to it' do
      create(:application_choice)
      total_number_of_choices_passed = application_choices.count + 1
      result = described_class.call(application_choices: ApplicationChoice.all)
      expect(result.count).to eq(total_number_of_choices_passed)
    end
  end

  describe 'days_to_respond vs updated_at DESC' do
    it 'sorts by days_to_respond if RBD is in the future' do
      choice_one = create(:application_choice, :awaiting_provider_decision, reject_by_default_at: 1.day.from_now.end_of_day, updated_at: 2.minutes.ago)
      choice_two = create(:application_choice, :awaiting_provider_decision, reject_by_default_at: 2.days.from_now.end_of_day, updated_at: 1.minute.ago)

      expect(described_class.call(application_choices: ApplicationChoice.all)).to eq [choice_one, choice_two]
    end

    it 'sorts by updated_at DESC if RBD is in the past' do
      choice_one = create(:application_choice, :awaiting_provider_decision, reject_by_default_at: 2.days.ago.end_of_day, updated_at: 2.minutes.ago)
      choice_two = create(:application_choice, :awaiting_provider_decision, reject_by_default_at: 2.days.ago.end_of_day, updated_at: 1.minute.ago)

      expect(described_class.call(application_choices: ApplicationChoice.all)).to eq [choice_two, choice_one]
    end

    it 'sorts by updated_at DESC if not awaiting_provider_decision' do
      choice_one = create(:application_choice, :offer, reject_by_default_at: 1.day.from_now.end_of_day, updated_at: 2.minutes.ago)
      choice_two = create(:application_choice, :offer, reject_by_default_at: 2.days.from_now.end_of_day, updated_at: 1.minute.ago)

      expect(described_class.call(application_choices: ApplicationChoice.all)).to eq [choice_two, choice_one]
    end
  end
end
