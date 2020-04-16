require 'rails_helper'

RSpec.describe SupportInterface::ProviderUserForm do
  let(:email_address) { 'provider@example.com' }
  let(:provider_ids) { [] }
  let(:form_params) do
    {
      first_name: 'Jane',
      last_name: 'Smith',
      email_address: email_address,
      provider_ids: provider_ids,
    }
  end

  subject(:provider_user_form) { described_class.new(form_params) }

  describe 'validations' do
    context 'email address exists' do
      before { allow(ProviderUser).to receive(:exists?).with(email_address: email_address).and_return(true) }

      it 'is invalid' do
        expect(provider_user_form.valid?).to be false
        expect(provider_user_form.errors[:email_address]).not_to be_empty
      end
    end

    context 'provider_ids are blank' do
      it 'is invalid' do
        expect(provider_user_form.valid?).to be false
        expect(provider_user_form.errors[:provider_ids]).not_to be_empty
      end
    end
  end

  describe '.permissions_for' do
    let(:provider_user) { create(:provider_user, :with_provider) }

    before { provider_user.provider_permissions.first.update(manage_users: true) }

    it 'returns provider permissions for the given user' do
      permissions = described_class.permissions_for(provider_user)

      expect(permissions).to be_a(ProviderPermissionsOptions)
      expect(permissions.manage_users).to eq(provider_user.providers.map(&:id))
    end
  end
end
