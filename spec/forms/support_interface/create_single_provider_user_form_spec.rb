require 'rails_helper'

RSpec.describe SupportInterface::CreateSingleProviderUserForm do
  let(:email_address) { 'provider@example.com' }
  let(:first_name) { 'Fred' }
  let(:last_name) { 'Smith' }
  let(:provider) { create(:provider, id: 2) }
  let(:provider_permissions) do
    {
      provider_permission: {
        provider_id: provider.id,
      },
    }
  end
  let(:form_params) do
    {
      first_name: first_name,
      last_name: last_name,
      email_address: email_address,
      provider_permissions: provider_permissions,
      provider_id: provider.id,
    }
  end

  subject(:provider_user_form) { described_class.new(form_params) }

  describe 'validations' do
    context 'first name must be present' do
      let(:first_name) { '' }

      it 'is invalid' do
        expect(provider_user_form.valid?).to be false
        expect(provider_user_form.errors[:first_name]).not_to be_empty
      end
    end

    context 'last name must be present' do
      let(:last_name) { '' }

      it 'is invalid' do
        expect(provider_user_form.valid?).to be false
        expect(provider_user_form.errors[:last_name]).not_to be_empty
      end
    end

    context 'email address must be present' do
      let(:email_address) { '' }

      it 'is invalid' do
        expect(provider_user_form.valid?).to be false
        expect(provider_user_form.errors[:email_address]).not_to be_empty
      end
    end

    context 'provider with user exists?' do
      it 'is invalid' do
        create(:provider_user, email_address: email_address, providers: [provider])

        expect(provider_user_form.valid?).to be false
        expect(provider_user_form.errors[:email_address]).not_to be_empty
      end
    end
  end
end
