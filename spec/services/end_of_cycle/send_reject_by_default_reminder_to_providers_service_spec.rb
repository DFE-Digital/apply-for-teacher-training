require 'rails_helper'

RSpec.describe EndOfCycle::SendRejectByDefaultReminderToProvidersService do
  describe '#call' do
    context 'user was notified in a previous cycle', time: after_apply_deadline do
      it 'creates a chased record' do
        user = create(:provider_user, :with_provider, :with_notifications_enabled)
        provider = user.providers.first
        create(:chaser_sent,
               chased: user,
               chaser_type: :respond_to_applications_before_reject_by_default_date,
               created_at: 1.year.ago)

        expect { described_class.new(provider).call }.to change(ChaserSent, :count).by 1
      end

      it 'sends an email' do
        user = create(:provider_user, :with_provider, :with_notifications_enabled)
        provider = user.providers.first
        create(:chaser_sent,
               chased: user,
               chaser_type: :respond_to_applications_before_reject_by_default_date,
               created_at: 1.year.ago)
        expect { described_class.new(provider).call }
          .to have_enqueued_mail(
            ProviderMailer, :respond_to_applications_before_reject_by_default_date
          )
      end
    end

    context 'user has already been sent the email', time: after_apply_deadline do
      it 'does not create another chaser sent record' do
        user = create(:provider_user, :with_provider, :with_notifications_enabled)
        provider = user.providers.first
        create(:chaser_sent, chased: user, chaser_type: :respond_to_applications_before_reject_by_default_date)

        expect { described_class.new(provider).call }.not_to change(ChaserSent, :count)
      end

      it 'does not send an email' do
        user = create(:provider_user, :with_provider, :with_notifications_enabled)
        create(:chaser_sent, chased: user, chaser_type: :respond_to_applications_before_reject_by_default_date)

        provider = user.providers.first
        described_class.new(provider).call
        expect { described_class.new(provider).call }
          .not_to have_enqueued_mail(
            ProviderMailer, :respond_to_applications_before_reject_by_default_date
          )
      end
    end
  end

  context 'user does not have notifications enabled' do
    it 'does not create another chaser sent record' do
      user = create(:provider_user, :with_provider, :with_notifications_enabled)
      provider = user.providers.first
      user.notification_preferences.update(application_received: false)

      expect { described_class.new(provider).call }.not_to change(ChaserSent, :count)
    end

    it 'does not send an email' do
      user = create(:provider_user, :with_provider, :with_notifications_enabled)
      user.notification_preferences.update(application_received: false)

      provider = user.providers.first
      described_class.new(provider).call
      expect { described_class.new(provider).call }
        .not_to have_enqueued_mail(
          ProviderMailer, :respond_to_applications_before_reject_by_default_date
        )
    end
  end
end
