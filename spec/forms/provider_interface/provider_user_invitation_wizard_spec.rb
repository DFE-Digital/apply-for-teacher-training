require 'rails_helper'

RSpec.describe ProviderInterface::ProviderUserInvitationWizard do
  let(:form_params) do
    {}
  end

  subject(:wizard) { described_class.new(form_params) }

  describe 'validations' do
    context 'with missing name and email fields' do
      let(:form_params) do
        {}
      end

      it 'first, last name and email address are required' do
        wizard.valid?(:details)

        expect(wizard.errors[:first_name]).not_to be_empty
        expect(wizard.errors[:last_name]).not_to be_empty
        expect(wizard.errors[:email_address]).not_to be_empty
      end
    end

    context 'with email address of an existing user' do
      let(:email_address) { 'provider@example.com' }
      let(:existing_user) { create(:provider_user, :with_provider, email_address: email_address) }

      before { form_params[:email_address] = existing_user.email_address }

      it 'is valid' do
        wizard.validate
        expect(wizard.errors[:email_address]).to be_empty
      end
    end
  end
end
