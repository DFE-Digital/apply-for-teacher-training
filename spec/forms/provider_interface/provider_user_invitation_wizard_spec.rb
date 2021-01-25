require 'rails_helper'

RSpec.describe ProviderInterface::ProviderUserInvitationWizard do
  def state_store_for(state)
    WizardStateStores::SessionStore.new(session: { 'key' => state.to_json }, key: 'key')
  end

  describe 'next_step' do
    it 'returns the providers page from the basic details page for a new user' do
      state_store = state_store_for({ providers: [123, 456] })
      wizard = described_class.new(state_store, current_step: 'details')
      expect(wizard.next_step).to eq([:providers])
    end

    it 'returns the permissions page from the details page for a single provider' do
      state_store = state_store_for({ providers: [123], single_provider: true })
      wizard = described_class.new(state_store, current_step: 'details')
      expect(wizard.next_step).to eq([:permissions, 123])
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

    it 'returns the review page from the first provider permissions page when permissions have been set and we are checking answers' do
      state_store = state_store_for({ providers: [123, 456], provider_permissions: { 123 => [], 456 => [] } })
      wizard = described_class.new(state_store, current_step: 'permissions', current_provider_id: '123')
      wizard.checking_answers = true
      expect(wizard.next_step).to eq([:check])
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

    it 'returns the details page from the permissions page for a single provider' do
      state_store = state_store_for({ providers: [123], provider_permissions: { 123 => [] }, single_provider: true })
      wizard = described_class.new(state_store, current_step: 'permissions', current_provider_id: '123')
      expect(wizard.previous_step).to eq([:details])
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
    it 'ignores permissions attributes if view applications attr is true' do
      state_store = state_store_for(first_name: 'Bob', email_address: 'bob@example.com')

      wizard = described_class.new(
        state_store,
        current_step: 'details',
        view_applications_only: 'true',
        provider_permissions: { 123 => { permissions: %w[make_decisions], provider_id: 111 } },
      )

      expect(wizard.provider_permissions[123]).to have_key(:provider_id)
      expect(wizard.provider_permissions[123]).not_to have_key(:permissions)
    end

    it 'assigns permissions attributes if view applications attr is not true' do
      state_store = state_store_for(first_name: 'Bob', email_address: 'bob@example.com')

      wizard = described_class.new(
        state_store,
        current_step: 'details',
        view_applications_only: 'false',
        provider_permissions: { 123 => { permissions: %w[make_decisions] } },
      )

      expect(wizard.provider_permissions[123][:permissions]).to eq(%w[make_decisions])
    end
  end

  describe 'validations' do
    context 'with missing name and email fields' do
      it 'first, last name and email address are required' do
        state_store = state_store_for({})
        wizard = described_class.new(state_store, current_step: 'details')

        wizard.valid?

        expect(wizard.errors.keys).to contain_exactly(:first_name, :last_name, :email_address)
      end
    end

    context 'with email address of an existing user' do
      it 'is valid' do
        existing_user = create(:provider_user, :with_provider, email_address: 'provider@example.com')
        state_store = state_store_for({})
        wizard = described_class.new(state_store, email_address: existing_user.email_address, current_step: 'details')

        wizard.valid?

        expect(wizard.errors[:email_address]).to be_empty
      end
    end

    context 'permissions step' do
      it 'is invalid if permissions not selected' do
        state_store = state_store_for({})
        wizard = described_class.new(state_store, current_step: 'permissions')

        wizard.valid?

        expect(wizard.errors[:view_applications_only]).not_to be_empty
      end

      it 'is valid if permissions are selected' do
        state_store = state_store_for({})
        wizard = described_class.new(state_store, current_step: 'permissions', view_applications_only: 'false')

        wizard.valid?

        expect(wizard.errors[:view_applications_only]).to be_empty
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
