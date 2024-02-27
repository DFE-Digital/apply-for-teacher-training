require 'rails_helper'

RSpec.describe SupportInterface::ProviderOnboardingMonitor do
  let!(:provider) { create(:provider, :no_users) }
  let!(:course) { create(:course, :open, provider:) }
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

      context 'when a provider only has courses in the previous year' do
        let!(:course) { create(:course, :open, :previous_year, provider:) }

        it 'does not return the provider' do
          expect(described_class.new.providers_with_no_users).to be_empty
        end
      end

      context 'when a provider has multiple courses in the current year' do
        let!(:another_course) { create(:course, :open, provider:) }

        it 'returns the provider and no duplicates' do
          expect(described_class.new.providers_with_no_users).to contain_exactly(provider)
        end
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

      context 'when a provider only has courses in the previous year' do
        let!(:course) { create(:course, :open, :previous_year, provider:) }

        it 'does not return the provider' do
          expect(described_class.new.providers_where_no_user_has_logged_in).to be_empty
        end
      end
    end
  end

  describe '.permissions_not_set_up' do
    context 'when a permission is not set up and has an open course' do
      let!(:permission) { create(:provider_relationship_permissions, :not_set_up_yet, :with_open_course) }

      it 'returns the permission' do
        expect(described_class.new.permissions_not_set_up).to contain_exactly(permission)
      end
    end

    context 'when a permission is not set up but does not have an open course' do
      let!(:permission) { create(:provider_relationship_permissions, :not_set_up_yet) }

      it 'does not return the permission' do
        expect(described_class.new.permissions_not_set_up).to be_empty
      end
    end

    context 'when a permission has been set up' do
      let!(:permission) { create(:provider_relationship_permissions, :with_open_course) }

      it 'does not return the permission' do
        expect(described_class.new.permissions_not_set_up).to be_empty
      end
    end
  end

  describe '.no_decisions_in_last_7_days' do
    %w[
      rejected_at
      offered_at
      offer_changed_at
      offer_withdrawn_at
      offer_deferred_at
      conditions_not_met_at
      recruited_at
    ].each do |decision_timestamp|
      context "when the #{decision_timestamp} is within the last 7 days for at least one application" do
        before do
          recent = 3.days.ago
          aged = 8.days.ago

          travel_temporarily_to(2.weeks.ago) do
            create(:application_choice, course_option: build(:course_option, course:), decision_timestamp => recent)
            create(:application_choice, course_option: build(:course_option, course:), decision_timestamp => aged)
          end
        end

        it 'does not return the provider' do
          expect(described_class.new.no_decisions_in_last_7_days).to be_empty
        end
      end

      context "when the #{decision_timestamp} is over 7 days ago for all applications" do
        before do
          aged = 8.days.ago

          travel_temporarily_to(2.weeks.ago) do
            create(:application_choice, course_option: build(:course_option, course:), decision_timestamp => aged)
            create(:application_choice, course_option: build(:course_option, course:), decision_timestamp => aged)
          end
        end

        it 'returns the provider and the date of the last decision' do
          expect(described_class.new.no_decisions_in_last_7_days).to contain_exactly(provider)
          expect(described_class.new.no_decisions_in_last_7_days.first.last_decision).to be_within(1.second).of(8.days.ago)
        end
      end
    end

    context 'when a provider’s application was rejected by default in the last 7 days' do
      let!(:application) { create(:application_choice, course_option: build(:course_option, course:), rejected_at: 6.days.ago, rejected_by_default: true) }

      it 'returns the provider' do
        expect(described_class.new.no_decisions_in_last_7_days).to contain_exactly(provider)
      end
    end

    context 'when a provider only has courses in the previous year' do
      let!(:course) { create(:course, :open, :previous_year, provider:) }
      let!(:application) { create(:application_choice, course_option: build(:course_option, course:), offered_at: 3.weeks.ago) }

      it 'does not return the provider' do
        expect(described_class.new.providers_where_no_user_has_logged_in).to be_empty
      end
    end

    context 'when the provider has received no applications' do
      it 'does not return the provider' do
        expect(described_class.new.no_decisions_in_last_7_days).to be_empty
      end
    end

    context 'when a provider has never made a decision' do
      let!(:application) { create(:application_choice, course_option: build(:course_option, course:)) }

      it 'returns the provider and the date of the last decision' do
        expect(described_class.new.no_decisions_in_last_7_days).to contain_exactly(provider)
        expect(described_class.new.no_decisions_in_last_7_days.first.last_decision).to be_nil
      end
    end
  end
end
