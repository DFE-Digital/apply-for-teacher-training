require 'rails_helper'

RSpec.describe ProviderInterface::ProviderRelationshipPermissionsSetupWizard do
  def state_store_for(state)
    { described_class::STATE_STORE_KEY => state.to_json }
  end

  describe 'next_step' do
    it 'returns the permissions info page from the provider relationships page' do
      state_store = state_store_for({})
      wizard = described_class.new(state_store, current_step: 'provider_relationships')
      expect(wizard.next_step).to eq([:info])
    end

    it 'returns the first provider relationship permissions page from the info page' do
      state_store = state_store_for({ provider_relationships: [123, 456] })
      wizard = described_class.new(state_store, current_step: 'info')
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
  end

  describe 'previous_step' do
    it 'returns the start page from the provider relationships page' do
      state_store = state_store_for({})
      wizard = described_class.new(state_store, current_step: 'provider_relationships')
      expect(wizard.previous_step).to eq([:start])
    end

    it 'returns provider relationships page from the permissions info page' do
      state_store = state_store_for({})
      wizard = described_class.new(state_store, current_step: 'info')
      expect(wizard.previous_step).to eq([:provider_relationships])
    end

    it 'returns the permissions information page from the first provider permissions page' do
      state_store = state_store_for({ provider_relationships: [123, 456], provider_relationship_permissions: { 123 => {} } })
      wizard = described_class.new(state_store, current_step: 'permissions', current_provider_relationship_id: '123')
      expect(wizard.previous_step).to eq([:info])
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
          'provider_relationship_permissions' => { '123' => { 'make_decisions' => [''], 'view_safeguarding_information' => %w[training] } },
        )

        expect(wizard.valid?(:permissions)).to be false
        expect(wizard.errors.keys).to eq(%i[make_decisions])
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

      expect(JSON.parse(state_store[described_class::STATE_STORE_KEY]).symbolize_keys).to eq({
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

      expect(state_store[described_class::STATE_STORE_KEY]).to be_nil
    end
  end
end
