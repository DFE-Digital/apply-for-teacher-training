require 'rails_helper'

RSpec.describe PromptInactiveProviderUsersWorker do
  include ActiveSupport::Testing::TimeHelpers

  let(:worker) { instance_double(ActiveJob::ConfiguredJob) }

  before do
    allow(PromptInactiveProviderUsersBatchWorker).to receive(:set).and_return(worker)
    allow(worker).to receive(:perform_later)
  end

  describe '#perform' do
    it 'prompts soon-to-be inactive provider users' do
      travel_to Time.zone.parse('2026-07-22 12:00:00') do
        should_prompt = create(:provider_user, :with_provider, last_signed_in_at: Time.zone.parse('2025-08-05 12:00:00'))
        should_not_prompt = create(:provider_user, :with_provider, last_signed_in_at: Time.zone.parse('2025-08-04 12:00:00'))

        described_class.new.perform

        expect(PromptInactiveProviderUsersBatchWorker).to have_received(:set)
        expect(worker).to have_received(:perform_later).with([should_prompt.id], 2.weeks.from_now.to_date)

        expect(worker).not_to have_received(:perform_later).with([should_not_prompt.id], anything)
      end
    end

    it 'prompts users who have never signed in but were created almost a year ago' do
      travel_to Time.zone.parse('2026-07-22 12:00:00') do
        should_prompt = create(:provider_user, :with_provider, last_signed_in_at: nil, created_at: Time.zone.parse('2025-08-05 12:00:00'))
        should_not_prompt = create(:provider_user, :with_provider, last_signed_in_at: nil, created_at: Time.zone.parse('2025-08-04 12:00:00'))

        described_class.new.perform

        expect(PromptInactiveProviderUsersBatchWorker).to have_received(:set)
        expect(worker).to have_received(:perform_later).with([should_prompt.id], 2.weeks.from_now.to_date)

        expect(worker).not_to have_received(:perform_later).with([should_not_prompt.id], anything)
      end
    end

    it 'only prompts users on their prompt date and not after it has passed' do
      travel_to Time.zone.parse('2026-07-22 12:00:00') do
        should_prompt = create(:provider_user, :with_provider, last_signed_in_at: Time.zone.parse('2025-08-05 12:00:00'))
        should_not_prompt = create(:provider_user, :with_provider, last_signed_in_at: Time.zone.parse('2025-08-02 12:00:00'))

        described_class.new.perform

        expect(PromptInactiveProviderUsersBatchWorker).to have_received(:set)
        expect(worker).to have_received(:perform_later).with([should_prompt.id], 2.weeks.from_now.to_date)

        expect(worker).not_to have_received(:perform_later).with([should_not_prompt.id], anything)
      end
    end

    it 'does not prompt a recently added but never signed in user' do
      travel_to Time.zone.parse('2026-07-22 12:00:00') do
        create(:provider_user, :with_provider, last_signed_in_at: nil, created_at: 2.months.ago)

        described_class.new.perform

        expect(PromptInactiveProviderUsersBatchWorker).not_to have_received(:set)
      end
    end

    it 'does not prompt an active user' do
      travel_to Time.zone.parse('2026-07-22 12:00:00') do
        create(:provider_user, :with_provider, last_signed_in_at: 1.week.ago)

        described_class.new.perform

        expect(PromptInactiveProviderUsersBatchWorker).not_to have_received(:set)
      end
    end

    it 'prompts users regardless of the time they signed in 11 months and 2 weeks ago' do
      travel_to Time.zone.parse('2026-07-22 12:00:00') do
        should_prompt = create(
          :provider_user,
          :with_provider,
          last_signed_in_at: Time.zone.parse('2025-08-05 15:59:59'),
        )

        described_class.new.perform

        expect(worker).to have_received(:perform_later).with([should_prompt.id], 2.weeks.from_now.to_date)
      end
    end

    it 'batches users in groups of 100' do
      travel_to Time.zone.parse('2026-07-22 12:00:00') do
        create_list(
          :provider_user,
          101,
          :with_provider,
          last_signed_in_at: Time.zone.parse('2025-08-05 12:00:00'),
        )

        described_class.new.perform

        expect(worker).to have_received(:perform_later).twice
      end
    end
  end
end
