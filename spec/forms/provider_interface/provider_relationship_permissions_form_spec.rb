require 'rails_helper'

RSpec.describe ProviderInterface::ProviderRelationshipPermissionsForm do
  let(:permissions) { create(:provider_relationship_permissions) }

  subject(:form) do
    described_class.new(permissions: permissions)
  end

  describe '#assign_permissions_attributes' do
    it 'assigns permissions attributes for accredited and training permissions' do
      allow(permissions).to receive(:assign_attributes)

      form.assign_permissions_attributes({ training_provider_can_view_safeguarding_information: 'true' })

      expect(permissions).to have_received(:assign_attributes)
        .with({
          ratifying_provider_can_make_decisions: false,
          training_provider_can_make_decisions: false,
          ratifying_provider_can_view_safeguarding_information: false,
          training_provider_can_view_safeguarding_information: 'true',
        })
    end
  end

  describe '#update!' do
    let(:permissions_attrs) do
      { ratifying_provider_can_make_decisions: 'true', training_provider_can_make_decisions: 'true' }
    end

    before do
      allow(permissions).to receive(:update!).and_return(true)
    end

    it 'updates accredited and training provider permissions models' do
      form.update!(permissions_attrs)

      expect(permissions).to have_received(:update!)
        .with({
          ratifying_provider_can_make_decisions: 'true',
          training_provider_can_make_decisions: 'true',
          ratifying_provider_can_view_safeguarding_information: false,
          training_provider_can_view_safeguarding_information: false,
        })
    end
  end
end
