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
        expect(provider_user_form).not_to be_valid
        expect(provider_user_form.errors[:provider_ids]).not_to be_empty
      end
    end

    context 'with provider_ids for providers the current user can manage' do
      it 'is valid' do
        provider_user_form.valid?
        expect(provider_user_form.errors[:provider_ids]).to be_empty
      end
    end

    context 'name fields' do
      it 'are required' do
        provider_user_form.valid?

        expect(provider_user_form.errors[:first_name]).not_to be_empty
        expect(provider_user_form.errors[:last_name]).not_to be_empty
      end
    end

    context 'with email address of an existing user' do
      let(:email_address) { 'provider@example.com' }
      let(:existing_user) { create(:provider_user, :with_provider, email_address: email_address) }

      before { form_params[:email_address] = existing_user.email_address }

      it 'is valid' do
        expect(provider_user_form).to be_valid
      end
    end
  end

  describe '#available_providers' do
    it 'returns a collection of providers the current provider user can assign to other users' do
      expect(provider_user_form.available_providers).to eq([provider])
    end
  end

  describe '#build' do
    let(:email_address) { 'provider@example.com' }
    let(:form_params) do
      {
        first_name: 'Jane',
        last_name: 'Smith',
        email_address: email_address,
        provider_ids: provider_ids,
        current_provider_user: provider_user,
      }
    end

    context 'for a new user' do
      it 'returns a new user' do
        expect(provider_user_form.build.persisted?).to be false
      end
    end

    context 'for an existing user' do
      let!(:existing_user) { create(:provider_user, :with_provider, email_address: email_address) }

      it 'modifies and returns the existing user' do
        expect(provider_user_form.build.persisted?).to be true
        expect(provider_user_form.build).to eq(existing_user)
      end
    end
  end
end
