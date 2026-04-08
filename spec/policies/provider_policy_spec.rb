require 'rails_helper'

RSpec.describe ProviderPolicy do
  subject(:policy) { described_class }

  let(:provider) { create(:provider) }
  let(:provider_user) { create(:provider_user, providers: [provider]) }

  permissions :manage_organisation_permissions? do
    context 'when the user does not have permission to manage organisations' do
      it 'denies access' do
        expect(policy).not_to permit(provider_user, provider)
      end
    end

    context 'when the user has permission to manage organisations' do
      it 'permits access' do
        permissions = ProviderPermissions.find_or_create_by!(provider:, provider_user:)
        permissions.update!(manage_organisations: true)
        expect(policy).to permit(provider_user, provider)
      end
    end
  end
end
