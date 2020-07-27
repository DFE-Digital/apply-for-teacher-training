require 'rails_helper'

RSpec.describe ProviderInterface::ProviderUserInvitationWizard do
  def state_store_for(state)
    { described_class::STATE_STORE_KEY => state.to_json }
  end

  describe 'next_step' do
    it 'returns the providers page from the basic details page for a new user' do
      state_store = state_store_for({})
      wizard = described_class.new(state_store, current_step: 'details')
      expect(wizard.next_step).to eq([:providers])
    end

    it 'returns the first provider permissions page from the providers page for a new user' do
      state_store = state_store_for({ providers: [123, 456] })
      wizard = described_class.new(state_store, current_step: 'providers')
      expect(wizard.next_step).to eq([:permissions, 123])
    end

    it 'returns the second provider permissions page from the first provider permissions page for a new user' do
      state_store = state_store_for({ providers: [123, 456], provider_permissions: { 123 => [] } })
      wizard = described_class.new(state_store, current_step: 'providers', current_provider_id: '123')
      expect(wizard.next_step).to eq([:permissions, 456])
    end

    it 'returns the review page from the last provider permissions page for a new user' do
      state_store = state_store_for({ providers: [123, 456], provider_permissions: { 123 => [], 456 => [] } })
      wizard = described_class.new(state_store, current_step: 'providers', current_provider_id: '456')
      expect(wizard.next_step).to eq([:check])
    end
  end

  describe 'previous_step' do
    it 'returns the providers page from the basic details page for a new user' do
      state_store = state_store_for({})
      wizard = described_class.new(state_store, current_step: 'details')
      expect(wizard.previous_step).to eq([:index])
    end

    it 'returns the first provider permissions page from the providers page for a new user' do
      state_store = state_store_for({ providers: [123, 456] })
      wizard = described_class.new(state_store, current_step: 'providers')
      expect(wizard.previous_step).to eq([:details])
    end

    it 'returns the providers page from the first provider permissions page for a new user' do
      state_store = state_store_for({ providers: [123, 456], provider_permissions: { 123 => [] } })
      wizard = described_class.new(state_store, current_step: 'permissions', current_provider_id: '123')
      expect(wizard.previous_step).to eq([:providers])
    end

    it 'returns the first provider permissions page from the last provider permissions page for a new user' do
      state_store = state_store_for({ providers: [123, 456], provider_permissions: { 123 => [], 456 => [] } })
      wizard = described_class.new(state_store, current_step: 'permissions', current_provider_id: '456')
      expect(wizard.previous_step).to eq([:permissions, 123])
    end

    it 'returns the last provider permissions page from the review page for a new user' do
      state_store = state_store_for({ providers: [123, 456], provider_permissions: { 123 => [], 456 => [] } })
      wizard = described_class.new(state_store, current_step: 'check')
      expect(wizard.previous_step).to eq([:permissions, 456])
    end
  end

  describe 'initializer' do
    it 'deserializes state' do
      state_store = state_store_for(first_name: 'Bob', email_address: 'bob@example.com')

      wizard = described_class.new(state_store, current_step: 'details')

      expect(wizard.first_name).to eq 'Bob'
      expect(wizard.last_name).to be_nil
      expect(wizard.email_address).to eq 'bob@example.com'
    end
  end

  describe '#save_state!' do
    it 'serializes state to state store' do
      state_store = state_store_for(first_name: 'Bob', email_address: 'bob@example.com')
      wizard = described_class.new(state_store)
      wizard.last_name = 'Roberts'
      wizard.email_address = 'bob@roberts.com'

      wizard.save_state!

      expect(JSON.parse(state_store[described_class::STATE_STORE_KEY]).symbolize_keys).to eq({
        first_name: 'Bob',
        last_name: 'Roberts',
        email_address: 'bob@roberts.com',
      })
    end
  end

  describe '#clear_state!' do
    it 'purges all state' do
      state_store = state_store_for(first_name: 'Bob', email_address: 'bob@example.com')
      wizard = described_class.new(state_store, current_step: 'details')
      wizard.last_name = 'Roberts'

      wizard.clear_state!

      expect(state_store[described_class::STATE_STORE_KEY]).to be_nil
    end
  end

  describe 'validations' do
    context 'with missing name and email fields' do
      it 'first, last name and email address are required' do
        state_store = state_store_for({})
        wizard = described_class.new(state_store, current_step: 'check')

        wizard.valid?(:details)

        expect(wizard.errors[:first_name]).not_to be_empty
        expect(wizard.errors[:last_name]).not_to be_empty
        expect(wizard.errors[:email_address]).not_to be_empty
      end
    end

    context 'with email address of an existing user' do
      it 'is valid' do
        existing_user = create(:provider_user, :with_provider, email_address: 'provider@example.com')
        state_store = state_store_for({})
        wizard = described_class.new(state_store, email_address: existing_user.email_address)

        wizard.validate

        expect(wizard.errors[:email_address]).to be_empty
      end
    end
  end

  describe '#email_address=' do
    it 'downcases and removes whitespace before and after on write' do
      state_store = state_store_for({})
      wizard = described_class.new(state_store, current_step: 'details')
      wizard.email_address = '  Bob@eXample.coM  '
      expect(wizard.email_address).to eq 'bob@example.com'
    end
  end
end
