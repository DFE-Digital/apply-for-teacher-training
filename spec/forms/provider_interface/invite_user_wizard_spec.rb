require 'rails_helper'
RSpec.describe ProviderInterface::InviteUserWizard do
  let(:store) { instance_double(WizardStateStores::RedisStore) }
  let(:email) { 'name@example.com' }
  let(:provider) { create(:provider) }

  subject(:wizard) do
    described_class.new(
      store,
      provider:,
      first_name: 'firstname',
      last_name: 'lastname',
      email_address: email,
    )
  end

  before { allow(store).to receive(:read) }

  describe 'validations' do
    it_behaves_like 'an email address valid for notify'

    context 'presence checks' do
      it { is_expected.to validate_presence_of(:first_name) }
      it { is_expected.to validate_presence_of(:last_name) }
      it { is_expected.to validate_presence_of(:email_address) }
    end

    context 'when the email is invalid' do
      let(:email) { 'invalid email' }

      it 'validates the email address format' do
        expect(wizard).not_to be_valid
        expect(wizard.errors[:email_address]).to contain_exactly('Enter an email address in the correct format, like name@example.com')
      end
    end

    context 'when a user exists with the given email' do
      let(:email) { 'existing_email@email.com' }

      context 'the email is already associated with provider' do
        let!(:existing_user) { create(:provider_user, email_address: email, providers: [provider]) }

        it 'validates the email address is a duplicate' do
          expect(wizard).not_to be_valid
          expect(wizard.errors[:email_address]).to contain_exactly("A user with this email address already has access to #{provider.name}")
        end
      end

      context 'the email is not associated with provider' do
        let!(:existing_user) { create(:provider_user, email_address: email) }

        it 'validates the email address is not a duplicate' do
          expect(wizard).to be_valid
        end
      end

      context 'an email with different capitalisation is already associated with the provider' do
        let(:email) { 'DifferentlyCased@Alphabet.Com' }
        let!(:existing_user) { create(:provider_user, email_address: email, providers: [provider]) }

        it 'validates the email address is a duplicate' do
          expect(wizard).not_to be_valid
          expect(wizard.errors[:email_address]).to contain_exactly("A user with this email address already has access to #{provider.name}")
        end
      end
    end
  end
end
