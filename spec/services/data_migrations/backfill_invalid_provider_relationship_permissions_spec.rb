require 'rails_helper'

RSpec.describe DataMigrations::BackfillInvalidProviderRelationshipPermissions do
  let!(:invalid_permission) do
    permission = create(:provider_relationship_permissions)
    permission.update_columns(
      training_provider_can_view_safeguarding_information: false,
      ratifying_provider_can_view_safeguarding_information: false,
      training_provider_can_view_diversity_information: false,
      ratifying_provider_can_view_diversity_information: false,
    )

    permission
  end

  let!(:valid_permission) do
    create(
      :provider_relationship_permissions,
      training_provider_can_view_safeguarding_information: false,
      ratifying_provider_can_view_safeguarding_information: true,
      training_provider_can_view_diversity_information: true,
      ratifying_provider_can_view_diversity_information: false,
    )
  end

  it 'udpates invalid permissions to become valid' do
    described_class.new.change

    expect(invalid_permission.reload).to be_valid
  end

  it 'updates invalid permission attributes to true' do
    described_class.new.change

    expect(invalid_permission.reload.attributes).to include(
      'training_provider_can_view_safeguarding_information' => true,
      'ratifying_provider_can_view_safeguarding_information' => true,
      'training_provider_can_view_diversity_information' => true,
      'ratifying_provider_can_view_diversity_information' => true,
    )
  end

  it 'does not update valid permissions' do
    described_class.new.change

    expect(valid_permission.reload.attributes).to include(
      'training_provider_can_view_safeguarding_information' => false,
      'ratifying_provider_can_view_safeguarding_information' => true,
      'training_provider_can_view_diversity_information' => true,
      'ratifying_provider_can_view_diversity_information' => false,
    )
  end

  it 'updates the invalid permission audit log', with_audited: true do
    expect { described_class.new.change }.to change(invalid_permission.audits, :count).by(1)
  end
end
