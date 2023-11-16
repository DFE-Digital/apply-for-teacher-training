require 'rails_helper'

RSpec.describe ProviderInterface::SortApplicationChoices, time: Time.zone.local(2021, 1, 1) do
  describe 'decorates models with' do
    let(:model) do
      create(:application_choice, :awaiting_provider_decision)
      described_class.call(application_choices: ApplicationChoice.all).first
    end

    it 'task_view_group' do
      expect(model).to respond_to(:task_view_group)
    end
  end

  describe 'task view groups' do
    let(:application_choice) do
      described_class.call(application_choices: ApplicationChoice.all).first
    end

    it '#inactive' do
      create(:application_choice, :inactive)
      expect(application_choice.task_view_group).to eq(1)
    end

    it '#awaiting_provider_decision' do
      create(:application_choice, :awaiting_provider_decision)
      expect(application_choice.task_view_group).to eq(2)
    end

    it '#deferred_offers_pending_reconfirmation' do
      create(:application_choice, :offer_deferred, :previous_year)
      expect(application_choice.task_view_group).to eq(3)
    end

    it '#give_feedback_for_rbd' do
      create(:application_choice, :rejected_by_default, rejection_reason: nil, structured_rejection_reasons: nil, rejected_at: Time.zone.parse(ProviderInterface::SortApplicationChoices::RBD_FEEDBACK_LAUNCH_TIMESTAMP))
      expect(application_choice.task_view_group).to eq(4)
    end

    it '#interviewing' do
      create(:application_choice, :interviewing)
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
      create(:application_choice, :offer_deferred)
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
        create(:application_choice, :interviewing),
        # --- 4
        create(:application_choice, :awaiting_provider_decision),
        create(:application_choice, :awaiting_provider_decision),
        # --- 3
        create(:application_choice, :rejected_by_default),
        # --- 2
        create(:application_choice, :awaiting_provider_decision),
        create(:application_choice, :awaiting_provider_decision),
        # --- 1
        create(:application_choice, :offer_deferred, :previous_year),
      ]
    end

    it 'according to their task_view_group, rbd and updated_at' do
      expected = application_choices.reverse
      result = described_class.call(application_choices: ApplicationChoice.all)
      expect(result).to match_array(expected)
    end

    it 'includes all applications passed to it' do
      create(:application_choice)
      total_number_of_choices_passed = application_choices.count + 1
      result = described_class.call(application_choices: ApplicationChoice.all)
      expect(result.count).to eq(total_number_of_choices_passed)
    end
  end
end
