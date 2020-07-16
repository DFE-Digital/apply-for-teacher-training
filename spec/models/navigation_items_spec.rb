require 'rails_helper'

RSpec.describe NavigationItems do
  describe '.for_provider_interface' do
    let(:provider) { create(:provider) }
    let(:provider_user) { create(:provider_user, providers: [provider]) }
    let(:controller) { ProviderInterface::ProviderInterfaceController }

    subject(:navigation_items) { NavigationItems.for_provider_interface(provider_user, controller) }

    context 'when the user can manage organisations and there are no provider relationships to manage' do
      before { provider_user.provider_permissions.find_by(provider: provider).update!(manage_organisations: true) }

      it 'does not include a link to Organisations' do
        expect(navigation_items.map(&:text)).not_to include('Organisations')
      end
    end

    context 'when the user can manage organisations and there are provider relationships to manage' do
      before do
        provider_user.provider_permissions.find_by(provider: provider).update!(manage_organisations: true)
        create(:provider_relationship_permissions, training_provider: provider)
      end

      it 'includes a link to Organisations' do
        expect(navigation_items.map(&:text)).to include('Organisations')
      end
    end
  end
end
