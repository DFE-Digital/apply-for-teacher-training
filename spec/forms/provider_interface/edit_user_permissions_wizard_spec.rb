require 'rails_helper'
RSpec.describe ProviderInterface::EditUserPermissionsWizard do
  describe '.from_model' do
    let(:provider_permissions) { build_stubbed(:provider_permissions, make_decisions: true, view_safeguarding_information: true) }
    let(:store_value) { {} }
    let(:store) { instance_double(WizardStateStores::RedisStore, read: store_value) }
    let(:wizard) { described_class.from_model(store, provider_permissions) }

    context 'when there is nothing saved in the state store' do
      it 'initializes a wizard from the given model' do
        expect(wizard.permissions).to contain_exactly('make_decisions', 'view_safeguarding_information')
      end
    end

    context 'when there is data saved in the state store' do
      let(:store_value) { { permissions: ['manage_users'] }.to_json }

      it 'initializes a wizard from the stored data' do
        expect(wizard.permissions).to contain_exactly('manage_users')
      end
    end
  end
end
