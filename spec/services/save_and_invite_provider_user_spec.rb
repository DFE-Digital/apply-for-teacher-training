require 'rails_helper'

RSpec.describe SaveAndInviteProviderUser do
  let(:form) do
    SupportInterface::ProviderUserForm.new(
      email_address: 'test+invite_provider_user@example.com',
      first_name: 'Firstname',
      last_name: 'Lastname',
      provider_permissions: { '10' => { provider_permission: { provider_id: 10 }, active: true } },
    )
  end
  let(:provider_user) { form.build }
  let(:save_service) do
    SaveProviderUser.new(
      provider_user: provider_user,
      provider_permissions: [],
      deselected_provider_permissions: [],
    )
  end
  let(:invite_service) { instance_double(InviteProviderUser, call!: true, notify: true) }

  describe '#initialize' do
    it 'requires a form, create service and invite service' do
      expect { described_class.new }.to raise_error(ArgumentError)

      expect {
        described_class.new(form: form, save_service: save_service, invite_service: invite_service)
      }.not_to raise_error
    end
  end

  describe '#call!' do
    subject(:service) do
      described_class.new(form: form, save_service: save_service, invite_service: invite_service)
    end

    it 'saves the user' do
      expect { service.call }.to change { ProviderUser.count }.by(1)
    end

    context 'form is invalid' do
      it 'returns false' do
        allow(form).to receive(:valid?).and_return(false)

        expect(service.call).to eq(false)
      end
    end

    context 'an error occurs in create service' do
      before do
        allow(save_service).to receive(:call!).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'exits the transactioni and raises the error' do
        expect { service.call }.to raise_error(ActiveRecord::RecordInvalid)

        expect(invite_service).not_to have_received(:call!)
      end
    end

    context 'an error occurs in invite service' do
      before { allow(invite_service).to receive(:call!).and_raise(Exception) }

      it 'rolls back the transaction and raises the error' do
        expect { service.call }.to raise_error(Exception).and change(ProviderUser, :count).by(0)
      end
    end

    context 'a DfeSignInAPIError occurs' do
      before { allow(invite_service).to receive(:call!).and_raise(DfeSignInAPIError) }

      it 'rolls back the transaction' do
        expect { service.call }.not_to change(ProviderUser, :count)
      end

      it 'notifies Sentry' do
        allow(Raven).to receive(:capture_exception)
        service.call
        expect(Raven).to have_received(:capture_exception)
      end

      it 'populates form errors' do
        service.call

        expect(service.form.errors).not_to be_empty
      end
    end
  end
end
