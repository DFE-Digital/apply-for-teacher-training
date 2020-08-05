require 'rails_helper'

RSpec.describe ProviderInterface::SetupProviderRelationshipPermissions do
  describe '.call' do
    let(:permission_1) { create(:provider_relationship_permissions, setup_at: nil) }
    let(:permission_2) { create(:provider_relationship_permissions, setup_at: nil) }

    context 'with valid data' do
      let(:permissions_data) do
        {
          permission_1.id => { 'make_decisions' => %w[training], 'view_safeguarding_information' => %w[training ratifying] },
          permission_2.id => { 'make_decisions' => %w[ratifying], 'view_safeguarding_information' => %w[training] },
        }
      end

      it 'returns true' do
        expect(described_class.call(permissions_data)).to be true
      end

      it 'updates a batch of ProviderRelationshipPermissions records' do
        described_class.call(permissions_data)
        permission_1.reload
        permission_2.reload

        expect(permission_1.setup_at).not_to be_a DateTime
        expect(permission_1.training_provider_can_make_decisions).to be true
        expect(permission_1.ratifying_provider_can_make_decisions).to be false
        expect(permission_1.training_provider_can_view_safeguarding_information).to be true
        expect(permission_1.ratifying_provider_can_view_safeguarding_information).to be true

        expect(permission_2.setup_at).not_to be_a DateTime
        expect(permission_2.training_provider_can_make_decisions).to be false
        expect(permission_2.ratifying_provider_can_make_decisions).to be true
        expect(permission_2.training_provider_can_view_safeguarding_information).to be true
        expect(permission_2.ratifying_provider_can_view_safeguarding_information).to be false
      end
    end

    context 'when attempting to update a record which does not exist' do
      it 'raises the underlying ActiveRecord error' do
        expect { described_class.call('666' => {}) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when attempting to update raises an error' do
      let(:permissions_data) do
        {
          permission_1.id => { 'make_decisions' => %w[training], 'view_safeguarding_information' => %w[ratifying] },
          permission_2.id => { 'make_decisions' => [''], 'view_safeguarding_information' => [''] },
        }
      end

      it 'returns false and rolls back updates to other permissions in the call' do
        expect { described_class.call(permissions_data) }.to raise_error(ActiveRecord::RecordInvalid)

        expect(permission_1.reload.setup_at).to be nil
      end
    end

    context 'when a record has been set up' do
      let(:permission) { create(:provider_relationship_permissions) }
      let(:permissions_data) { { permission.id => { 'make_decisions' => %w[training], 'view_safeguarding_information' => %w[ratifying] } } }

      it 'raises ProviderInterface::PermissionsSetupError' do
        expect { described_class.call(permissions_data) }.to raise_error(ProviderInterface::PermissionsSetupError)
      end
    end
  end
end
