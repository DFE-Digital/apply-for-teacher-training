require 'rails_helper'

RSpec.describe ProviderRelationshipPermissions do
  describe 'validations' do
    let(:setup_at) { Time.zone.now }

    subject(:permissions) do
      described_class.new(
        ratifying_provider: build_stubbed(:provider),
        training_provider: build_stubbed(:provider),
        ratifying_provider_can_view_safeguarding_information: true,
        setup_at: setup_at,
      )
    end

    it 'ensures at least one permission in each pair is active' do
      expect(permissions.valid?).to be false
      expect(permissions.errors.keys).to eq(%i[make_decisions])
    end

    context 'when permissions have not been set up' do
      let(:setup_at) { nil }

      it 'skips validation' do
        expect(permissions.valid?).to be true
      end
    end

    context 'when at least one permission in each pair is active' do
      it 'is a valid set of permissions' do
        permissions.training_provider_can_make_decisions = true

        expect(permissions.valid?).to be true
      end
    end
  end
end
