require 'rails_helper'

RSpec.describe ProviderInterface::ProviderRelationshipPermissionsForm do
  let(:permissions) { build_stubbed(:provider_relationship_permissions) }
  let(:permissions_attrs) { {} }

  subject(:form) do
    described_class.new(permissions_attrs.merge(permissions_model: permissions))
  end

  describe '#save!' do
    let(:permissions_attrs) do
      { make_decisions: %w[ratifying training] }
    end

    before do
      allow(permissions).to receive(:assign_attributes)
      allow(permissions).to receive(:save!)
    end

    it 'updates accredited and training provider permissions models' do
      form.save!

      expect(permissions).to have_received(:assign_attributes)
        .with({
          'ratifying_provider_can_make_decisions' => true,
          'training_provider_can_make_decisions' => true,
          'ratifying_provider_can_view_safeguarding_information' => false,
          'training_provider_can_view_safeguarding_information' => true,
        })

      expect(permissions).to have_received(:save!)
    end
  end
end
