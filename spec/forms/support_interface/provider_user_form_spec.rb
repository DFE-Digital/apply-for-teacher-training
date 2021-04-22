require 'rails_helper'

RSpec.describe SupportInterface::ProviderUserForm do
  let(:email_address) { 'provider@example.com' }
  let(:provider) { build_stubbed(:provider, id: 2) }
  let(:provider_permissions) do
    {
      provider.id => {
        provider_permission: {
          provider_id: provider.id,
        },
        active: true,
      },
    }
  end
  let(:section_complete_form_params) do
    {
      first_name: 'Jane',
      last_name: 'Smith',
      email_address: email_address,
      provider_permissions: provider_permissions,
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

    context 'provider permissions must be present' do
      let(:provider_permissions) { {} }

      it 'is invalid' do
        expect(provider_user_form.valid?).to be false
        expect(provider_user_form.errors[:provider_permissions]).not_to be_empty
      end
    end
  end
end
