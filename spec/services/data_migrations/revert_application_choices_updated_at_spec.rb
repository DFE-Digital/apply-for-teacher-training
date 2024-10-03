require 'rails_helper'

RSpec.describe DataMigrations::RevertApplicationChoicesUpdatedAt do
  describe '#change' do
    it 'enques jobs to RevertApplicationChoicesUpdatedAtWorker' do
      create(
        :application_choice,
        updated_at: Time.zone.parse('2024-9-3 13:00'),
        created_at: Time.zone.parse('2024-8-1'),
        status: :awaiting_provider_decision,
        current_recruitment_cycle_year: 2024,
      )

      expect { described_class.new.change }.to change(
        RevertApplicationChoicesUpdatedAtWorker.jobs, :size
      ).by(1)
    end

    context 'with limit' do
      it 'enques jobs to RevertApplicationChoicesUpdatedAtWorker' do
        create(
          :application_choice,
          updated_at: Time.zone.parse('2024-9-3 13:00'),
          created_at: Time.zone.parse('2024-8-1'),
          status: :awaiting_provider_decision,
          current_recruitment_cycle_year: 2024,
        )

        expect { described_class.new.change(limit: 20) }.to change(
          RevertApplicationChoicesUpdatedAtWorker.jobs, :size
        ).by(1)
      end
    end

    context 'with limit and provider_ids' do
      it 'enques jobs to RevertApplicationChoicesUpdatedAtWorker' do
        choice = create(
          :application_choice,
          updated_at: Time.zone.parse('2024-9-3 13:00'),
          created_at: Time.zone.parse('2024-8-1'),
          status: :awaiting_provider_decision,
          current_recruitment_cycle_year: 2024,
        )

        expect { described_class.new.change(limit: 20, provider_ids: choice.provider_ids) }.to change(
          RevertApplicationChoicesUpdatedAtWorker.jobs, :size
        ).by(1)
      end
    end

    context 'with limit, provider_ids and stagger_over' do
      it 'enques jobs to RevertApplicationChoicesUpdatedAtWorker' do
        choice = create(
          :application_choice,
          updated_at: Time.zone.parse('2024-9-3 13:00'),
          created_at: Time.zone.parse('2024-8-1'),
          status: :awaiting_provider_decision,
          current_recruitment_cycle_year: 2024,
        )

        expect { described_class.new.change(limit: 20, provider_ids: choice.provider_ids, stagger_over: 2) }.to change(
          RevertApplicationChoicesUpdatedAtWorker.jobs, :size
        ).by(1)
      end
    end
  end

  describe '#choices' do
    it 'returns the application choices that need updating' do
      provider = create(:provider)
      correct_choice_2024 = create(
        :application_choice,
        updated_at: Time.zone.parse('2024-9-3 13:00'),
        created_at: Time.zone.parse('2024-8-1'),
        status: :awaiting_provider_decision,
        current_recruitment_cycle_year: 2024,
        provider_ids: [provider.id],
      )
      correct_choice_2023 = create(
        :application_choice,
        updated_at: Time.zone.parse('2024-9-3 13:00'),
        created_at: Time.zone.parse('2024-8-1'),
        status: :awaiting_provider_decision,
        current_recruitment_cycle_year: 2023,
        provider_ids: [provider.id],
      )
      choice_with_wrong_updated_at = create(
        :application_choice,
        updated_at: Time.zone.parse('2024-9-4 13:00'),
        created_at: Time.zone.parse('2024-8-1'),
        status: :awaiting_provider_decision,
        current_recruitment_cycle_year: 2024,
        provider_ids: [provider.id],
      )
      choice_with_wrong_created_at = create(
        :application_choice,
        updated_at: Time.zone.parse('2024-9-3 13:00'),
        created_at: Time.zone.parse('2024-9-3 13:00'),
        status: :awaiting_provider_decision,
        current_recruitment_cycle_year: 2024,
        provider_ids: [provider.id],
      )
      choice_with_wrong_status = create(
        :application_choice,
        updated_at: Time.zone.parse('2024-9-3 13:00'),
        created_at: Time.zone.parse('2024-8-1'),
        status: :unsubmitted,
        current_recruitment_cycle_year: 2024,
        provider_ids: [provider.id],
      )
      choice_with_wrong_recruitment_cycle = create(
        :application_choice,
        updated_at: Time.zone.parse('2024-9-3 13:00'),
        created_at: Time.zone.parse('2024-8-1'),
        status: :awaiting_provider_decision,
        current_recruitment_cycle_year: 2022,
        provider_ids: [provider.id],
      )

      choices = described_class.new.choices(100, [provider.id])

      expect(choices).to include(
        correct_choice_2024,
        correct_choice_2023,
      )

      expect(choices).not_to include(
        choice_with_wrong_updated_at,
        choice_with_wrong_created_at,
        choice_with_wrong_status,
        choice_with_wrong_recruitment_cycle,
      )
    end

    it 'returns the application choices with limit' do
      provider = create(:provider)
      choice_2024 = create(
        :application_choice,
        updated_at: Time.zone.parse('2024-9-3 13:00'),
        created_at: Time.zone.parse('2024-8-1'),
        status: :awaiting_provider_decision,
        current_recruitment_cycle_year: 2024,
        provider_ids: [provider.id],
      )
      choice_2023 = create(
        :application_choice,
        updated_at: Time.zone.parse('2024-9-3 13:00'),
        created_at: Time.zone.parse('2024-8-1'),
        status: :awaiting_provider_decision,
        current_recruitment_cycle_year: 2023,
        provider_ids: [provider.id],
      )

      choices = described_class.new.choices(1, [provider.id])

      expect(choices).to include(choice_2024)
      expect(choices).not_to include(choice_2023)
    end

    it 'returns the application choices with specific providers' do
      provider_1 = create(:provider)
      provider_2 = create(:provider)
      choice_2024 = create(
        :application_choice,
        updated_at: Time.zone.parse('2024-9-3 13:00'),
        created_at: Time.zone.parse('2024-8-1'),
        status: :awaiting_provider_decision,
        current_recruitment_cycle_year: 2024,
        provider_ids: [provider_1.id, provider_2.id],
      )
      choice_2023 = create(
        :application_choice,
        updated_at: Time.zone.parse('2024-9-3 13:00'),
        created_at: Time.zone.parse('2024-8-1'),
        status: :awaiting_provider_decision,
        current_recruitment_cycle_year: 2023,
        provider_ids: [provider_1.id, provider_2.id],
      )
      choice_with_wrong_provider_combination = create(
        :application_choice,
        updated_at: Time.zone.parse('2024-9-3 13:00'),
        created_at: Time.zone.parse('2024-8-1'),
        status: :awaiting_provider_decision,
        current_recruitment_cycle_year: 2023,
        provider_ids: [provider_1],
      )

      choices = described_class.new.choices(100, [provider_1.id, provider_2.id])

      expect(choices).to include(choice_2024, choice_2023)
      expect(choices).not_to include(choice_with_wrong_provider_combination)
    end
  end
end
