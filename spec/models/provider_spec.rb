require 'rails_helper'

RSpec.describe Provider do
  describe 'associations' do
    it { is_expected.to belong_to(:vendor).optional }
  end

  describe 'delegations' do
    it { is_expected.to delegate_method(:name).to(:vendor).with_prefix.allow_nil }
  end

  describe '#onboarded?' do
    it 'depends on the presence of a signed Data sharing agreement' do
      provider_with_dsa = create(:provider)
      provider_without_dsa = create(:provider, :unsigned)

      expect(provider_with_dsa).to be_onboarded
      expect(provider_without_dsa).not_to be_onboarded
    end
  end

  describe '#lacks_admin_users?' do
    let(:provider) { create(:provider, :no_users) }

    it 'is true if there are no admin users and the provider has one course' do
      create(:course, provider:)
      expect(provider.lacks_admin_users?).to be true
    end

    it 'is true if there are no users with both manage users and manage organisations and the provider has one course' do
      create(:course, provider:)
      create(:provider_user, :with_manage_users, providers: [provider])
      expect(provider.lacks_admin_users?).to be true
    end

    it 'is false if the provider has no courses' do
      expect(provider.lacks_admin_users?).to be false
    end

    it 'is false if there is at least one admin user and the provider has one course' do
      create(:course, provider:)
      create(:provider_user, :with_manage_users, :with_manage_organisations, providers: [provider])
      expect(provider.lacks_admin_users?).to be false
    end
  end

  describe '.with_courses' do
    let(:provider) { create(:provider) }

    it 'doesnt return providers with no courses' do
      expect(described_class.with_courses).to eq([])
    end

    it 'returns a provider that has a course' do
      create(:course, provider:)
      expect(described_class.with_courses).to eq([provider])
    end

    it 'only returns providers with courses' do
      create(:course, provider:)
      create(:provider)
      expect(described_class.with_courses).to eq([provider])
    end
  end

  describe 'selectable_school?' do
    context 'provider is selectable_school' do
      let(:provider) { create(:provider, selectable_school: true) }

      context 'when Current Cycle is 2024', time: mid_cycle(2024) do
        it 'is not selectable school' do
          expect(provider).to be_selectable_school
        end
      end

      context 'when Current Cycle is greater than 2024', time: mid_cycle(2025) do
        it 'is selectable school' do
          expect(provider).to be_selectable_school
        end
      end
    end

    context 'provider is not selectable_school' do
      let(:provider) { create(:provider, selectable_school: false) }

      context 'when Current Cycle is 2024', time: mid_cycle(2024) do
        it 'is not selectable school' do
          expect(provider).to be_selectable_school
        end
      end

      context 'when Current Cycle is greater than 2024', time: mid_cycle(2025) do
        it 'is not selectable school' do
          expect(provider).not_to be_selectable_school
        end
      end
    end
  end
end
