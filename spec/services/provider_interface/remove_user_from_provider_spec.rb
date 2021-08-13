require 'rails_helper'

RSpec.describe ProviderInterface::RemoveUserFromProvider do
  let(:user_to_remove) { create(:provider_user, :with_provider) }
  let(:provider) { user_to_remove.providers.first }
  let(:current_provider_user) { create(:provider_user) }
  let(:service) do
    described_class.new(
      current_provider_user: current_provider_user,
      provider: provider,
      user_to_remove: user_to_remove,
    )
  end

  describe '#call!' do
    context 'when the current user does not have the manage users permission' do
      it 'raises an access denied error' do
        expect { service.call! }.to raise_error(ProviderInterface::AccessDenied)
      end
    end

    context 'when the current user can manage users for the given provider' do
      let(:current_provider_user) { create(:provider_user, :with_manage_users, providers: [provider]) }

      context 'when the user_to_remove does not belong to the given provider' do
        let(:provider) { create(:provider) }

        it 'raises a not found error' do
          expect { service.call! }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      it 'deletes the relationship between user and provider' do
        expect { service.call! }.to change(user_to_remove.providers, :count).by(-1)
        expect(user_to_remove.providers).not_to include(provider)
      end

      it 'audits the change', with_audited: true do
        expect { service.call! }.to change(user_to_remove.associated_audits, :count).by(1)
        expect(user_to_remove.associated_audits.last.comment).to eq('User was deleted')
      end
    end
  end
end
