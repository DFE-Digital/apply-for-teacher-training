require 'rails_helper'

RSpec.describe ProviderInterface::ProviderUserForm do
  let(:provider_user) { create(:provider_user, :with_provider) }
  let(:provider) { provider_user.providers.first }
  let(:manageable_user) { create(:provider_user, providers: [provider]) }
  let(:provider_ids) { [provider.id] }
  let(:form_params) { { current_provider_user: provider_user, provider_ids: provider_ids } }

  subject(:provider_user_form) { described_class.new(form_params) }

  before { provider_user.providers.first.provider_permissions.update(manage_users: true) }

  describe 'validations' do
    context 'with provider_ids for providers the current user cannot manage' do
      let(:another_provider) { create(:provider) }
      let(:provider_ids) { [provider.id, another_provider.id] }

      it 'is invalid' do
        expect(provider_user_form.valid?).to be false
        expect(provider_user_form.errors[:provider_ids]).not_to be_empty
      end
    end

    context 'with provider_ids for providers the current user can manage' do
      it 'is valid' do
        provider_user_form.valid?
        expect(provider_user_form.errors[:provider_ids]).to be_empty
      end
    end
  end

  describe '#available_providers' do
    it 'returns a collection of providers the current provider user can assign to other users' do
      expect(provider_user_form.available_providers).to eq([provider])
    end
  end
end
