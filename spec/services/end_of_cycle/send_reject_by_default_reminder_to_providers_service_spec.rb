require 'rails_helper'

RSpec.describe EndOfCycle::SendRejectByDefaultReminderToProvidersService do
  describe '#call' do
    context 'user was notified in a previous cycle', time: after_apply_deadline do
      let(:user) { create(:provider_user, :with_provider, :with_notifications_enabled) }
      let(:provider) { user.providers.first }

      before do
        create(:chaser_sent,
               chased: user,
               chaser_type: :respond_to_applications_before_reject_by_default_date,
               created_at: 1.year.ago)
      end

      it 'creates a chased record' do
        expect { described_class.new(provider).call }.to change(ChaserSent, :count).by 1
      end

      it 'sends an email' do
        expect { described_class.new(provider).call }
          .to have_enqueued_mail(
            ProviderMailer, :respond_to_applications_before_reject_by_default_date
          )
      end
    end

    context 'user has already been sent the email', time: after_apply_deadline do
      let(:user) { create(:provider_user, :with_provider, :with_notifications_enabled) }
      let(:provider) { user.providers.first }

      before do
        create(:chaser_sent, chased: user, chaser_type: :respond_to_applications_before_reject_by_default_date)
      end

      it 'does not create another chaser sent record' do
        expect { described_class.new(provider).call }.not_to change(ChaserSent, :count)
      end

      it 'does not send an email' do
        expect { described_class.new(provider).call }
          .not_to have_enqueued_mail(
            ProviderMailer, :respond_to_applications_before_reject_by_default_date
          )
      end
    end
  end

  context 'user does not have notifications enabled' do
    let(:user) { create(:provider_user, :with_provider, :with_notifications_enabled) }
    let(:provider) { user.providers.first }

    before do
      user.notification_preferences.update(application_received: false)
    end

    it 'does not create another chaser sent record' do
      expect { described_class.new(provider).call }.not_to change(ChaserSent, :count)
    end

    it 'does not send an email' do
      expect { described_class.new(provider).call }
        .not_to have_enqueued_mail(
          ProviderMailer, :respond_to_applications_before_reject_by_default_date
        )
    end
  end
end
