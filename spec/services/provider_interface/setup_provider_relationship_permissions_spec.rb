require 'rails_helper'

RSpec.describe ProviderInterface::SetupProviderRelationshipPermissions do
  describe '.call' do
    let(:permission_1) { create(:provider_relationship_permissions, setup_at: nil) }
    let(:permission_2) { create(:provider_relationship_permissions, setup_at: nil) }

    it 'sets setup_at' do
      expect { described_class.call([permission_1, permission_2]) }
        .to(change { permission_1.setup_at }.and(change { permission_2.setup_at }))
    end

    context 'when attempting to update raises an error' do
      let(:permissions_data) do
        [
          permission_1,
          create(:provider_relationship_permissions, setup_at: nil, training_provider_can_make_decisions: false, ratifying_provider_can_make_decisions: false),
        ]
      end

      it 'returns false and rolls back updates to other permissions in the call' do
        expect { described_class.call(permissions_data) }.to(raise_error(ActiveRecord::RecordInvalid))

        expect(permission_1.reload.setup_at).to be_nil
      end
    end

    context 'when a record has already been set up' do
      let(:setup_at) { 1.hour.ago }
      let(:permissions) { [create(:provider_relationship_permissions, setup_at: setup_at)] }

      it 'updates the record' do
        permissions.first.ratifying_provider_can_make_decisions = true
        expect { described_class.call(permissions) }.to(change { permissions.first.updated_at })
        expect(permissions.first.reload.setup_at.to_fs(:db)).to eq(setup_at.to_fs(:db))
      end
    end
  end
end
