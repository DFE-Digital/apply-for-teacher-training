require 'rails_helper'

RSpec.describe Provider, type: :model do
  describe '.with_users_manageable_by' do
    it 'scopes results to providers where the user is permitted to manage other users' do
      provider = create(:provider)
      create(:provider)
      provider_user = create(:provider_user, providers: [provider])
      provider_user.provider_permissions.update_all(manage_users: true)

      expect(described_class.with_users_manageable_by(provider_user)).to eq([provider])
    end
  end

  describe '#onboarded?' do
    it 'depends on the presence of a signed Data sharing agreement' do
      provider_with_dsa = create(:provider, :with_signed_agreement)
      provider_without_dsa = create(:provider)

      expect(provider_with_dsa).to be_onboarded
      expect(provider_without_dsa).not_to be_onboarded
    end
  end

  describe '#all_associated_accredited_providers_onboarded?' do
    let(:provider) { create(:provider) }

    subject(:result) { provider.all_associated_accredited_providers_onboarded? }

    it 'returns true when the accredited bodies are all onboarded' do
      create(:course, provider: provider, accredited_provider: create(:provider, :with_signed_agreement))

      expect(result).to be true
    end

    it 'returns false when some accredited bodies are onboarded' do
      create(:course, provider: provider, accredited_provider: create(:provider, :with_signed_agreement))
      create(:course, provider: provider, accredited_provider: create(:provider))

      expect(result).to be false
    end

    it 'returns false when there are no accredited bodies' do
      create(:course, provider: provider, accredited_provider: create(:provider))

      expect(result).to be false
    end
  end

  describe '#all_courses_open_in_current_cycle?' do
    let(:provider) { create(:provider) }

    subject(:result) { provider.all_courses_open_in_current_cycle? }

    it 'is true if all the provider’s other courses are open on apply except courses hidden in Find' do
      create(:course, :open_on_apply, provider: provider)
      create(:course, provider: provider, exposed_in_find: false)

      expect(result).to be true
    end

    it 'is false if the provider’s other courses are a mixture of open on apply and open on UCAS' do
      create(:course, provider: provider, exposed_in_find: true, open_on_apply: false)

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
        create(:course, :open_on_apply, provider: provider)
        create(:course, accredited_provider: provider, exposed_in_find: true, open_on_apply: false)

        expect(result).to be true
      end
    end
  end
end
