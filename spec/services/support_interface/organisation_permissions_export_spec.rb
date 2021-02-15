require 'rails_helper'

RSpec.describe SupportInterface::OrganisationPermissionsExport do
  let(:training_provider) { create(:provider) }
  let(:ratifying_provider) { create(:provider) }
  let(:provider_relationship_permissions) do
    create(:provider_relationship_permissions,
           ratifying_provider: ratifying_provider,
           training_provider: training_provider)
  end
  let(:audit_entry) { create(:provider_relationship_permissions_audit, provider_relationship_permissions: provider_relationship_permissions, changes: changes) }
  let(:changes) do
    {
      'training_provider_can_make_decisions' => [false, true],
      'ratifying_provider_can_make_decisions' => [false, true],
      'training_provider_can_view_diversity_information' => [false, true],
      'ratifying_provider_can_view_diversity_information' => [true, false],
      'training_provider_can_view_safeguarding_information' => true,
      'ratifying_provider_can_view_safeguarding_information' => false,
    }
  end

  describe '#data_for_export' do
    it 'exports permissions changes' do
      audit_user = ProviderUser.find(audit_entry.user_id)
      audit_user.providers << create(:provider)

      exported_data = described_class.new.data_for_export
      created_at, user_id, username, provider_code, provider_name,
        training_provider_code, training_provider_name,
        training_provider_permissions_enabled, training_provider_permissions_disabled,
        ratifying_provider_code, ratifying_provider_name,
        ratifying_provider_permissions_enabled, ratifying_provider_permissions_disabled = exported_data.first.values

      expect(created_at.to_s).to eq(audit_entry.created_at.to_s)
      expect(user_id).to eq(audit_entry.user_id)
      expect(username).to eq(audit_entry.username)
      expect(provider_code).to eq(audit_user.providers.first.code)
      expect(provider_name).to eq(audit_user.providers.first.name)
      expect(training_provider_code).to eq(training_provider.code)
      expect(training_provider_name).to eq(training_provider.name)
      expect(training_provider_permissions_enabled).to eq('make_decisions, view_diversity_information, view_safeguarding_information')
      expect(training_provider_permissions_disabled).to eq('')
      expect(ratifying_provider_code).to eq(ratifying_provider.code)
      expect(ratifying_provider_name).to eq(ratifying_provider.name)
      expect(ratifying_provider_permissions_enabled).to eq('make_decisions')
      expect(ratifying_provider_permissions_disabled).to eq('view_diversity_information, view_safeguarding_information')
    end

    context 'for audit entries made by support users' do
      it 'omits provider information' do
        audit_entry.update(user_id: create(:support_user).id)

        exported_data = described_class.new.data_for_export
        created_at, user_id, username, provider_code, provider_name,
          _training_provider_code, _training_provider_name,
          _training_provider_permissions_enabled, _training_provider_permissions_disabled,
          _ratifying_provider_code, _ratifying_provider_name,
          _ratifying_provider_permissions_enabled, _ratifying_provider_permissions_disabled = exported_data.first.values

        expect(created_at.to_s).to eq(audit_entry.created_at.to_s)
        expect(user_id).to eq(audit_entry.user_id)
        expect(username).to eq(audit_entry.username)
        expect(provider_code).to be_nil
        expect(provider_name).to be_nil
      end
    end
  end
end
