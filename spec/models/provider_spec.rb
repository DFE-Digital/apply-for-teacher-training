require 'rails_helper'

RSpec.describe Provider do
  describe '#onboarded?' do
    it 'depends on the presence of a signed Data sharing agreement' do
      provider_with_dsa = create(:provider)
      provider_without_dsa = create(:provider, :unsigned)

      expect(provider_with_dsa).to be_onboarded
      expect(provider_without_dsa).not_to be_onboarded
    end
  end

  describe '#all_courses_open_in_current_cycle?' do
    let(:provider) { create(:provider) }

    subject(:result) { provider.all_courses_open_in_current_cycle? }

    it 'is true if all the provider’s other courses are open on apply except courses hidden in Find' do
      create(:course, :open, provider:)
      create(:course, provider:, exposed_in_find: false)

      expect(result).to be true
    end

    it 'is false if the provider’s other courses are a mixture of open on apply and open on UCAS' do
      create(:course, provider:, exposed_in_find: true, open_on_apply: false)

      expect(result).to be false
    end

    it 'is false if the provider’s other courses including ratified courses are a mixture of open on Apply and open on UCAS' do
      create(:course, accredited_provider: provider, exposed_in_find: true, open_on_apply: false)

      expect(result).to be false
    end

    it 'is false if the provider has no courses' do
      expect(result).to be false
    end

    context 'exclude_ratified_courses: true' do
      subject(:result) { provider.all_courses_open_in_current_cycle?(exclude_ratified_courses: true) }

      it 'is true if the provider’s ratified courses are not open but its own are' do
        create(:course, :open, provider:)
        create(:course, accredited_provider: provider, exposed_in_find: true, open_on_apply: false)

        expect(result).to be true
      end
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
end
