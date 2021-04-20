require 'rails_helper'

RSpec.describe ProviderInterface::ProviderRelationshipPermissionsSetupWizard do
  def state_store_for(state)
    WizardStateStores::SessionStore.new(session: { 'key' => state.to_json }, key: 'key')
  end

  describe 'next_step' do
    it 'returns the first provider relationship permissions page from the organisations page' do
      state_store = state_store_for({ provider_relationships: [123, 456] })
      wizard = described_class.new(state_store, current_step: 'organisations')
      expect(wizard.next_step).to eq([:permissions, 123])
    end

    it 'returns the second provider relationship permissions page from the first provider relationship permissions page' do
      state_store = state_store_for({ provider_relationships: [123, 456], provider_relationship_permissions: { 123 => {} } })
      wizard = described_class.new(state_store, current_step: 'permissions', current_provider_relationship_id: '123')
      expect(wizard.next_step).to eq([:permissions, 456])
    end

    it 'returns the review page from the last provider relationship permissions page' do
      state_store = state_store_for({ provider_relationships: [123, 456], provider_relationship_permissions: { 123 => {}, 456 => {} } })
      wizard = described_class.new(state_store, current_step: 'permissions', current_provider_relationship_id: '456')
      expect(wizard.next_step).to eq([:check])
    end

    context 'with checking_answers param present' do
      it 'returns the review page from the first provider relationship permissions page' do
        state_store = state_store_for({ provider_relationships: [123, 456], provider_relationship_permissions: { 123 => {}, 456 => {} } })
        wizard = described_class.new(state_store, current_step: 'permissions', current_provider_relationship_id: '123', checking_answers: true)
        expect(wizard.next_step).to eq([:check])
      end
    end
  end

  describe 'previous_step' do
    it 'returns the organisations page from the first provider permissions page' do
      state_store = state_store_for({ provider_relationships: [123, 456], provider_relationship_permissions: { 123 => {} } })
      wizard = described_class.new(state_store, current_step: 'permissions', current_provider_relationship_id: '123')
      expect(wizard.previous_step).to eq([:organisations])
    end

    it 'returns the first provider relationship permissions page from the last provider relationship permissions page' do
      state_store = state_store_for({ provider_relationships: [123, 456], provider_relationship_permissions: { 123 => {}, 456 => {} } })
      wizard = described_class.new(state_store, current_step: 'permissions', current_provider_relationship_id: '456')
      expect(wizard.previous_step).to eq([:permissions, 123])
    end

    it 'returns the last provider relationship permissions page from the review page' do
      state_store = state_store_for({ provider_relationships: [123, 456], provider_relationship_permissions: { 123 => {}, 456 => {} } })
      wizard = described_class.new(state_store, current_step: 'check')
      expect(wizard.previous_step).to eq([:permissions, 456])
    end

    context 'with checking_answers param present' do
      it 'returns to the review page from the last provider relationship permissions page' do
        state_store = state_store_for({ provider_relationships: [123, 456], provider_relationship_permissions: { 123 => {}, 456 => {} } })
        wizard = described_class.new(state_store, current_step: 'permissions', current_provider_relationship_id: '456', checking_answers: true)
        expect(wizard.previous_step).to eq([:check])
      end
    end
  end

  describe 'initializer' do
    it 'deserializes state' do
      state_store = state_store_for({
        provider_relationships: [123],
        provider_relationship_permissions: { 123 => { make_decisions: %w[ratifying training], view_safeguarding_information: %w[training] } },
      })

      wizard = described_class.new(state_store, current_step: 'permissions')

      expect(wizard.provider_relationships).to eq([123])
      expect(wizard.provider_relationship_permissions['123']).to eq({
        'make_decisions' => %w[ratifying training],
        'view_safeguarding_information' => %w[training],
      })
    end

    it 'merges permissions attributes' do
      state_store = state_store_for({
        provider_relationships: [123, 456],
        provider_relationship_permissions: { '123' => { 'make_decisions' => %w[ratifying training], 'view_safeguarding_information' => %w[training] } },
      })

      wizard = described_class.new(state_store, current_step: 'permissions')
      wizard.save_state!

      attrs = {
        'current_step' => 'permissions',
        'provider_relationship_permissions' => {
          '456' => {
            'make_decisions' => %w[training], 'view_safeguarding_information' => %w[training ratifying]
          },
        },
      }

      wizard = described_class.new(state_store, attrs)

      expect(wizard.provider_relationship_permissions['123']).to eq({ 'make_decisions' => %w[ratifying training], 'view_safeguarding_information' => %w[training] })
      expect(wizard.provider_relationship_permissions['456']).to eq({ 'make_decisions' => %w[training], 'view_safeguarding_information' => %w[training ratifying] })
    end
  end

  describe 'validations' do
    context 'when no providers are selected for a permission' do
      it 'is invalid' do
        wizard = described_class.new(
          state_store_for({}),
          'current_provider_relationship_id' => '123',
          'provider_relationship_permissions' => { '123' => { 'make_decisions' => [''], 'view_safeguarding_information' => %w[training], 'view_diversity_information' => %w[training] } },
        )

        expect(wizard.valid?(:permissions)).to be false
        expect(wizard.errors.attribute_names).to eq([:'provider_relationship_permissions[123][make_decisions]'])
      end
    end
  end

  describe '#save_state!' do
    it 'serializes state to state store' do
      state_store = state_store_for({
        provider_relationships: [123],
        provider_relationship_permissions: { 123 => { make_decisions: %w[ratifying training], view_safeguarding_information: %w[training] } },
      })
      wizard = described_class.new(state_store)

      wizard.save_state!

      expect(JSON.parse(state_store.read).symbolize_keys).to eq({
        provider_relationships: [123],
        provider_relationship_permissions: {
          '123' => {
            'make_decisions' => %w[ratifying training],
            'view_safeguarding_information' => %w[training],
          },
        },
      })
    end
  end

  describe '#clear_state!' do
    it 'purges all state' do
      state_store = state_store_for({})
      wizard = described_class.new(state_store, current_step: 'info')

      wizard.clear_state!

      expect(state_store.read).to be_nil
    end
  end

  describe '#permissions_for_persistence' do
    it 'returns ProviderRelationshipPermissions records' do
      permission_one = create(:provider_relationship_permissions, :not_set_up_yet)
      permission_two = create(:provider_relationship_permissions, :not_set_up_yet)

      state_store = state_store_for({
        provider_relationships: [permission_one.id, permission_two.id],
        provider_relationship_permissions: {
          permission_one.id => { make_decisions: %w[ratifying training], view_safeguarding_information: %w[training] },
          permission_two.id => { make_decisions: %w[ratifying], view_safeguarding_information: %w[training], view_diversity_information: %w[training] },
        },
      })

      wizard = described_class.new(state_store, current_step: 'check')
      permissions = wizard.permissions_for_persistence
      draft_permission_one = permissions.find { |p| p.id == permission_one.id }
      draft_permission_two = permissions.find { |p| p.id == permission_two.id }

      expect(draft_permission_one.setup_at).to be_nil
      expect(draft_permission_one.training_provider_can_make_decisions).to be true
      expect(draft_permission_one.ratifying_provider_can_make_decisions).to be true
      expect(draft_permission_one.training_provider_can_view_safeguarding_information).to be true
      expect(draft_permission_one.ratifying_provider_can_view_safeguarding_information).to be false
      expect(draft_permission_one.training_provider_can_view_diversity_information).to be false
      expect(draft_permission_one.ratifying_provider_can_view_diversity_information).to be false

      expect(draft_permission_two.setup_at).to be_nil
      expect(draft_permission_two.training_provider_can_make_decisions).to be false
      expect(draft_permission_two.ratifying_provider_can_make_decisions).to be true
      expect(draft_permission_two.training_provider_can_view_safeguarding_information).to be true
      expect(draft_permission_two.ratifying_provider_can_view_safeguarding_information).to be false
      expect(draft_permission_two.training_provider_can_view_diversity_information).to be true
      expect(draft_permission_two.ratifying_provider_can_view_diversity_information).to be false
    end
  end
end
