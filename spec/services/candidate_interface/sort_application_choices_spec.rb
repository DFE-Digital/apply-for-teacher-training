require 'rails_helper'

RSpec.describe CandidateInterface::SortApplicationChoices do
  describe 'decorates models with' do
    let(:model) do
      create(:application_choice, :awaiting_provider_decision)
      described_class.call(application_choices: ApplicationChoice.all).first
    end

    it 'application_choices_group' do
      expect(model).to respond_to(:application_choices_group)
    end
  end

  describe '#application_choices_group' do
    let(:application_choice) do
      described_class.call(application_choices: ApplicationChoice.all).first
    end

    it 'when application has an offer' do
      create(:application_choice, :offer)
      expect(application_choice.application_choices_group).to eq(1)
    end

    it 'when application is unsubmitted' do
      create(:application_choice, :unsubmitted)
      expect(application_choice.application_choices_group).to eq(2)
    end

    it 'when application is application_not_sent' do
      create(:application_choice, :application_not_sent)
      expect(application_choice.application_choices_group).to eq(2)
    end

    it 'when application is cancelled' do
      create(:application_choice, :cancelled)
      expect(application_choice.application_choices_group).to eq(2)
    end

    it 'when application is rejected' do
      create(:application_choice, :rejected)
      expect(application_choice.application_choices_group).to eq(3)
    end

    it 'when application is conditions_not_met' do
      create(:application_choice, :conditions_not_met)
      expect(application_choice.application_choices_group).to eq(3)
    end

    it 'when application is interviewing' do
      create(:application_choice, :interviewing)
      expect(application_choice.application_choices_group).to eq(4)
    end

    it 'when application is inactive' do
      create(:application_choice, :inactive)
      expect(application_choice.application_choices_group).to eq(4)
    end

    it 'when application is awaiting_provider_decision' do
      create(:application_choice, :awaiting_provider_decision)
      expect(application_choice.application_choices_group).to eq(4)
    end

    it 'when application is declined' do
      create(:application_choice, :declined)
      expect(application_choice.application_choices_group).to eq(5)
    end

    it 'when application is withdrawn' do
      create(:application_choice, :withdrawn)
      expect(application_choice.application_choices_group).to eq(6)
    end

    it 'when application is offer withdrawn' do
      create(:application_choice, :offer_withdrawn)
      expect(application_choice.application_choices_group).to eq(6)
    end

    it 'when application status is not mapped' do
      create(:application_choice, :recruited)
      expect(application_choice.application_choices_group).to eq(10)
    end
  end

  describe '.call' do
    let(:application_choices) do
      [
        # --- 10
        create(:application_choice, :recruited),
        # --- 6
        create(:application_choice, :offer_withdrawn),
        create(:application_choice, :withdrawn),
        # --- 5
        create(:application_choice, :declined),
        # --- 4
        create(:application_choice, :awaiting_provider_decision, sent_to_provider_at: 1.minute.ago),
        create(:application_choice, :awaiting_provider_decision, sent_to_provider_at: Time.zone.now), # has more recent sent_to_provider_at, will appear first
        create(:application_choice, :inactive),
        create(:application_choice, :interviewing),
        # --- 3
        create(:application_choice, :rejected),
        create(:application_choice, :conditions_not_met),
        # --- 2
        create(:application_choice, :unsubmitted),
        create(:application_choice, :unsubmitted), # has more recent updated_at, will appear first
        create(:application_choice, :application_not_sent),
        create(:application_choice, :cancelled),
        # --- 1
        create(:application_choice, :offer),
      ]
    end

    it 'according to their application_choices_group and updated_at' do
      expected = application_choices.reverse
      result = described_class.call(application_choices: ApplicationChoice.all)
      expect(result).to match_array(expected)
    end
  end
end
