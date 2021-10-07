require 'rails_helper'

RSpec.describe SupportInterface::ProviderOnboardingMonitor do
  let!(:provider) { create(:provider) }
  let!(:user) { create(:provider_user, providers: [provider], last_signed_in_at: 1.day.ago) }

  describe '.providers_with_no_users' do
    context 'when a provider has at least one user' do
      it 'does not return the provider' do
        expect(described_class.new.providers_with_no_users).to be_empty
      end
    end

    context 'when a provider has no users' do
      let!(:user) { nil }

      it 'returns the provider' do
        expect(described_class.new.providers_with_no_users).to contain_exactly(provider)
      end
    end
  end

  describe '.providers_where_no_user_has_logged_in' do
    context 'when at least one of the provider users has logged in' do
      let!(:another_user) { create(:provider_user, providers: [provider], last_signed_in_at: nil) }

      it 'does not return the provider' do
        expect(described_class.new.providers_where_no_user_has_logged_in).to be_empty
      end
    end

    context 'when none of the provider users has logged in' do
      let!(:user) { create(:provider_user, providers: [provider], last_signed_in_at: nil) }

      it 'returns the provider' do
        expect(described_class.new.providers_where_no_user_has_logged_in).to contain_exactly(provider)
      end
    end
  end

  describe '.permissions_not_set_up' do
    context 'when at least one organisation permission is not set up for the provider' do
      before do
        create(:provider_relationship_permissions, :with_open_course, ratifying_provider: provider)
        create(:provider_relationship_permissions, :not_set_up_yet, :with_open_course, ratifying_provider: provider)
        create(:provider_relationship_permissions, :with_open_course, training_provider: provider)
      end

      it 'returns the provider' do
        expect(described_class.new.permissions_not_set_up).to contain_exactly(provider)
      end

      context 'when the provider has no users' do
        let!(:user) { nil }

        it 'does not return the provider' do
          expect(described_class.new.permissions_not_set_up).to be_empty
        end
      end

      context 'when the provider has no users that have logged in' do
        let!(:user) { create(:provider_user, providers: [provider], last_signed_in_at: nil) }

        it 'does not return the provider' do
          expect(described_class.new.permissions_not_set_up).to be_empty
        end
      end
    end

    context 'when all organisation permissions are set up for a provider' do
      before do
        create_list(:provider_relationship_permissions, 2, :with_open_course, ratifying_provider: provider)
        create_list(:provider_relationship_permissions, 2, :with_open_course, training_provider: provider)
      end

      it 'does not return the provider' do
        expect(described_class.new.permissions_not_set_up).to be_empty
      end
    end

    context 'when the provider has no open courses' do
      before { create(:provider_relationship_permissions, ratifying_provider: provider) }

      it 'does not return the provider' do
        expect(described_class.new.permissions_not_set_up).to be_empty
      end
    end
  end

  describe '.no_decisions_in_last_7_days' do
    let(:course) { create(:course, provider: provider) }

    context 'when a provider has made an offer on at least one application in the last 7 days' do
      let!(:application) { create(:application_choice, course: course, offered_at: 3.days.ago) }

      it 'does not return the provider' do
        expect(described_class.new.no_decisions_in_last_7_days).to be_empty
      end
    end

    context 'when a provider has rejected at least one application in the last 7 days' do
      let!(:application) { create(:application_choice, course: course, rejected_at: 6.days.ago) }

      it 'does not return the provider' do
        expect(described_class.new.no_decisions_in_last_7_days).to be_empty
      end
    end

    context 'when a provider’s application was rejected by default in the last 7 days' do
      let!(:application) { create(:application_choice, course: course, rejected_at: 6.days.ago, rejected_by_default: true) }

      it 'returns the provider' do
        expect(described_class.new.no_decisions_in_last_7_days).to contain_exactly(provider)
      end
    end

    context 'when the provider has received no applications' do
      it 'does not return the provider' do
        expect(described_class.new.no_decisions_in_last_7_days).to be_empty
      end
    end

    context 'when a provider has made decisions but over 7 days ago' do
      let!(:application) { create(:application_choice, course: course, offered_at: 8.days.ago) }

      it 'returns the provider and the date of the last decision' do
        expect(described_class.new.no_decisions_in_last_7_days).to contain_exactly(provider)
        expect(described_class.new.no_decisions_in_last_7_days.first.last_decision).to be_within(1.second).of(8.days.ago)
      end
    end

    context 'when a provider has never made a decision' do
      let!(:application) { create(:application_choice, course: course) }

      it 'returns the provider and the date of the last decision' do
        expect(described_class.new.no_decisions_in_last_7_days).to contain_exactly(provider)
        expect(described_class.new.no_decisions_in_last_7_days.first.last_decision).to be_nil
      end
    end
  end
end
