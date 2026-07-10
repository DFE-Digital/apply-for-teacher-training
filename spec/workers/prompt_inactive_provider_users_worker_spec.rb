require 'rails_helper'

RSpec.describe PromptInactiveProviderUsersWorker do
  include ActiveSupport::Testing::TimeHelpers

  describe '#perform' do
    it 'prompts soon-to-be inactive provider users' do
      travel_to Time.zone.parse('2026-1-1 12:00:00') do
        should_prompt = create(:provider_user, :with_provider, last_signed_in_at: 12.months.ago - 2.weeks)
        should_not_prompt = create(:provider_user, :with_provider, last_signed_in_at: 12.months.ago - 2.weeks - 1.day)

        mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)

        allow(ProviderMailer).to receive(:inactive_user_prompt).and_return(mail)

        described_class.new.perform

        expect(ProviderMailer).to have_received(:inactive_user_prompt).once.with(should_prompt, 2.weeks.from_now.to_date)
        expect(mail).to have_received(:deliver_later).once

        expect(ProviderMailer).not_to have_received(:inactive_user_prompt).with(should_not_prompt, anything)
      end
    end

    it 'prompts users who have never signed in but were created almost a year ago' do
      travel_to Time.zone.parse('2026-1-1 12:00:00') do
        should_prompt = create(:provider_user, :with_provider, last_signed_in_at: nil, created_at: 12.months.ago - 2.weeks)
        should_not_prompt = create(:provider_user, :with_provider, last_signed_in_at: nil, created_at: 12.months.ago - 2.weeks - 1.day)

        mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)

        allow(ProviderMailer).to receive(:inactive_user_prompt).and_return(mail)

        described_class.new.perform

        expect(ProviderMailer).to have_received(:inactive_user_prompt).once.with(should_prompt, 2.weeks.from_now.to_date)
        expect(mail).to have_received(:deliver_later).once

        expect(ProviderMailer).not_to have_received(:inactive_user_prompt).with(should_not_prompt, anything)
      end
    end

    it 'only prompts users on the prompt date and not again at a later date' do
      travel_to Time.zone.parse('2026-1-1 12:00:00') do
        should_prompt = create(:provider_user, :with_provider, last_signed_in_at: 12.months.ago - 2.weeks)
        should_not_prompt = create(:provider_user, :with_provider, last_signed_in_at: 12.months.ago - 2.weeks - 3.days)

        mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)

        allow(ProviderMailer).to receive(:inactive_user_prompt).and_return(mail)

        described_class.new.perform

        expect(ProviderMailer).to have_received(:inactive_user_prompt).once.with(should_prompt, 2.weeks.from_now.to_date)
        expect(mail).to have_received(:deliver_later).once

        expect(ProviderMailer).not_to have_received(:inactive_user_prompt).with(should_not_prompt, anything)
      end
    end

    it 'does not prompt a recently added but never signed in user' do
      travel_to Time.zone.parse('2026-1-1 12:00:00') do
        recently_added = create(:provider_user, :with_provider, last_signed_in_at: nil, created_at: 2.months.ago)

        mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)

        allow(ProviderMailer).to receive(:inactive_user_prompt).and_return(mail)

        described_class.new.perform

        expect(ProviderMailer).not_to have_received(:inactive_user_prompt).with(recently_added, anything)
      end
    end

    it 'does not prompt an active user' do
      travel_to Time.zone.parse('2026-1-1 12:00:00') do
        active_user = create(:provider_user, :with_provider, last_signed_in_at: 1.week.ago)

        mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)

        allow(ProviderMailer).to receive(:inactive_user_prompt).and_return(mail)

        described_class.new.perform

        expect(ProviderMailer).not_to have_received(:inactive_user_prompt).with(active_user, anything)
      end
    end
  end
end
