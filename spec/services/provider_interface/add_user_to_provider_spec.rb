require 'rails_helper'

RSpec.describe ProviderInterface::AddUserToProvider do
  let(:mailer_delivery) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }
  let(:actor) { create(:provider_user, :with_provider, :with_manage_users) }
  let(:provider) { actor.providers.first }
  let(:email_address) { Faker::Internet.email }
  let(:first_name) { 'Firstman' }
  let(:last_name) { 'Lastson' }
  let(:permissions) { ProviderPermissions::VALID_PERMISSIONS.map(&:to_s).sample(3) }
  let!(:service) do
    described_class.new(
      actor:,
      provider:,
      email_address:,
      first_name:,
      last_name:,
      permissions:,
    )
  end

  describe '#call!' do
    it 'attributes audits to the actor', :with_audited do
      expect { service.call! }.to change(Audited::Audit, :count).by(2)

      expect(Audited::Audit.second_to_last.auditable_type).to eq('ProviderUser')
      expect(Audited::Audit.second_to_last.user).to eq(actor)
      expect(Audited::Audit.last.auditable_type).to eq('ProviderPermissions')
      expect(Audited::Audit.last.user).to eq(actor)
    end

    context 'when the actor cannot manage users' do
      let(:actor) { create(:provider_user, :with_provider) }

      it 'raises a NotAuthorisedError' do
        expect { service.call! }.to raise_error(ProviderAuthorisation::NotAuthorisedError)
      end
    end

    context 'when the user already belongs to the provider' do
      let!(:existing_user) { create(:provider_user, providers: [provider], email_address:) }

      it 'raises a RecordNotUnique error and does not update the user’s details' do
        expect { service.call! }.to raise_error(ActiveRecord::RecordNotUnique)

        expect(existing_user.reload.first_name).not_to eq(first_name)
        expect(existing_user.reload.last_name).not_to eq(last_name)
      end
    end

    context 'when the provider user already exists but does not belong to the provider' do
      let!(:existing_user) { create(:provider_user, email_address:) }

      it 'updates the name of the user' do
        expect { service.call! }.to change { existing_user.reload.first_name }.to(first_name)
                                .and change { existing_user.reload.last_name }.to(last_name)
      end

      it 'creates a new ProviderPermissions object for the relationship with the specified permissions' do
        service.call!

        expect(existing_user.providers).to include(provider)

        provider_permissions = existing_user.provider_permissions.find_by(provider:)
        ProviderPermissions::VALID_PERMISSIONS.each do |permission|
          expect(provider_permissions.send(permission)).to eq(expected_permission_value(permission))
        end
      end

      it 'sends a permissions granted email to the user' do
        provider_user = ProviderUser.find_or_initialize_by(email_address:)
        allow(ProviderMailer).to receive(:permissions_granted).and_return(mailer_delivery)

        service.call!

        expect(ProviderMailer).to have_received(:permissions_granted).with(provider_user, provider, permissions, actor)
      end

      it 'does not create another notification preferences object' do
        expect { service.call! }.not_to change(ProviderUserNotificationPreferences, :count)
      end

      context 'the given email is a differently cased version of the existing provider user' do
        let(:email_address) { 'EmailAddress@Email.Com' }
        let!(:existing_user) { create(:provider_user, email_address: email_address.downcase) }

        it "doesn't raise an error" do
          expect { service.call! }.not_to raise_error
        end
      end
    end

    context 'when the provider user does not exist yet' do
      it 'creates a new ProviderUser with notification preferences' do
        expect { service.call! }.to change(ProviderUser, :count).by(1)

        new_user = ProviderUser.last
        expect(new_user.first_name).to eq(first_name)
        expect(new_user.last_name).to eq(last_name)
        expect(new_user.email_address).to eq(email_address)

        expect(new_user.notification_preferences).not_to be_nil
      end

      it 'creates a new ProviderPermissions object for the relationship with the specified permissions' do
        expect { service.call! }.to change(ProviderPermissions, :count).by(1)

        new_user = ProviderUser.last
        expect(new_user.providers).to include(provider)

        provider_permissions = new_user.provider_permissions.find_by(provider:)
        ProviderPermissions::VALID_PERMISSIONS.each do |permission|
          expect(provider_permissions.send(permission)).to eq(expected_permission_value(permission))
        end
      end
    end
  end

  def expected_permission_value(permission)
    permissions.include? permission.to_s
  end
end
