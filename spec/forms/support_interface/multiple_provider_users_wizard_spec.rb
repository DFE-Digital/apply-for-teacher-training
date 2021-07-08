require 'rails_helper'

RSpec.describe SupportInterface::MultipleProviderUsersWizard do
  subject(:form) do
    described_class.new(state_store: store)
  end

  let(:store) { instance_double(WizardStateStores::RedisStore) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:provider_users) }
  end

  describe '.build' do
    it 'returns a form with correct attributes' do
      provider_id = 1
      stored_users = {
        provider_users: [
          {
            'first_name' => 'Bob',
            'last_name' => 'Smith',
            'email_address' => 'bob@foo.com',
          },
          {
            'first_name' => 'Fred',
            'last_name' => 'Jones',
            'email_address' => 'fred@bar.com',
          },
        ],
      }

      allow(store).to receive(:read).and_return(stored_users.to_json)

      form = described_class.build(state_store: store, provider_id: provider_id)
      expected_attributes = {
        state_store: store,
        provider_id: provider_id,
        stored_provider_users: stored_users[:provider_users],
        provider_users: "Bob,Smith,bob@foo.com\nFred,Jones,fred@bar.com\n",
      }

      expect(form).to have_attributes(expected_attributes)
    end
  end

  describe '#all_single_provider_user_forms' do
    it 'converts provider users from state store to CreateSingleProviderUserForms' do
      stored_users = {
        provider_users: [
          {
            first_name: 'Bob',
            last_name: 'Smith',
            email_address: 'bob@foo.com',
            permissions: { manage_users: 'true' },
          },
        ],
      }

      provider = create(:provider)

      allow(store).to receive(:read).and_return(stored_users.to_json)

      forms = described_class.build(
        state_store: store,
        provider_id: provider.id,
      ).all_single_provider_user_forms

      form = forms.first

      expect(form).to be_kind_of(SupportInterface::CreateSingleProviderUserForm)
      expect(form.first_name).to eq('Bob')
      expect(form.last_name).to eq('Smith')
      expect(form.email_address).to eq('bob@foo.com')

      provider_permissions = form.provider_permissions
      expect(provider_permissions).to be_kind_of(ProviderPermissions)
      expect(provider_permissions.provider_id).to eq(provider.id)
      expect(provider_permissions.manage_users).to be(true)
    end
  end

  describe '#provider_user_count' do
    it 'returns the provider user count' do
      stored_users = {
        provider_users: [
          {
            first_name: 'Bob',
            last_name: 'Smith',
            email_address: 'bob@foo.com',
            permissions: { manage_users: true },
          },
        ],
      }

      allow(store).to receive(:read).and_return(stored_users.to_json)

      expect(described_class.new(state_store: store).provider_user_count).to eq(1)
    end
  end

  describe '#position_and_count' do
    it "returns provider users' position and count" do
      stored_users = {
        provider_users: [
          {
            first_name: 'Bob',
            last_name: 'Smith',
            email_address: 'bob@foo.com',
          },
          {
            first_name: 'Fred',
            last_name: 'Jones',
            email_address: 'fred@bar.com',
          },
        ],
      }

      allow(store).to receive(:read).and_return(stored_users.to_json)

      expect(described_class.new(state_store: store, index: 0).position_and_count).to eq(
        {
          position: 1,
          count: 2,
        },
      )
    end
  end

  describe '#provider_user_name' do
    it "returns the provider user's name" do
      stored_users = {
        provider_users: [
          {
            first_name: 'Bob',
            last_name: 'Smith',
            email_address: 'bob@foo.com',
          },
        ],
      }

      allow(store).to receive(:read).and_return(stored_users.to_json)

      expect(described_class.new(state_store: store).provider_user_name).to eq('Bob Smith')
    end
  end

  describe '#no_more_users_to_process?' do
    context 'there are no more users to process' do
      it 'returns true' do
        stored_users = {
          provider_users: [
            {
              first_name: 'Bob',
              last_name: 'Smith',
              email_address: 'bob@foo.com',
            },
          ],
        }

        allow(store).to receive(:read).and_return(stored_users.to_json)

        expect(
          described_class.new(state_store: store, index: 0).no_more_users_to_process?,
        )
        .to eq(true)
      end
    end

    context 'there are more users to process' do
      it 'returns false' do
        stored_users = {
          provider_users: [
            {
              first_name: 'Bob',
              last_name: 'Smith',
              email_address: 'bob@foo.com',
            },
            {
              first_name: 'Melanie',
              last_name: 'Jones',
              email_address: 'melanie@jones.com',
            },
          ],
        }

        allow(store).to receive(:read).and_return(stored_users.to_json)

        expect(
          described_class.new(state_store: store, index: 0).no_more_users_to_process?,
        ).to eq(false)
      end
    end
  end

  describe '#single_provider_user_form' do
    it 'returns an instance of CreateSingleProviderUserForm' do
      first_name = 'Bob'
      last_name = 'Smith'
      email_address = 'bob@foo.com'
      index = 0
      stored_users = {
        provider_users: [
          {
            first_name: first_name,
            last_name: last_name,
            email_address: email_address,
          },
        ],
      }

      allow(store).to receive(:read).and_return(stored_users.to_json)

      single_provider_user_form = described_class.new(state_store: store, provider_id: 1).single_provider_user_form(index)
      expected_attributes = {
        first_name: first_name,
        last_name: last_name,
        email_address: email_address,
        provider_id: 1,
      }

      expect(single_provider_user_form).to be_an_instance_of(SupportInterface::CreateSingleProviderUserForm)
      expect(single_provider_user_form).to have_attributes(expected_attributes)
    end
  end
end
