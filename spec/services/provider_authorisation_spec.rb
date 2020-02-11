require 'rails_helper'

RSpec.describe ProviderAuthorisation do
  include CourseOptionHelpers

  describe 'assert! methods' do
    it 'raise errors if the corresponding permission methods return false' do
      auth_context = ProviderAuthorisation.new(actor: nil)
      allow(auth_context).to receive(:can_make_offer?).and_return(true)
      expect { auth_context.assert_can_make_offer!(application_choice: nil) }.not_to raise_error
      allow(auth_context).to receive(:can_make_offer?).and_return(false)
      expect { auth_context.assert_can_make_offer!(application_choice: nil) }.to raise_error(ProviderAuthorisation::NotAuthorisedError)
    end
  end

  describe '#can_make_offer?' do
    context 'with provider user' do
      let(:agreement) { create(:provider_agreement) } # easiest way to associate provider and provider_user
      let(:provider_user) { agreement.provider_user }

      it 'is false if user is not associated with the provider that offers the course' do
        application_choice = create(:application_choice, :awaiting_provider_decision)
        auth_context = ProviderAuthorisation.new(actor: provider_user)
        expect(auth_context.can_make_offer?(application_choice: application_choice)).to be_falsy
      end

      it 'is true if user is associated with the provider that offers the course' do
        course_option = course_option_for_provider(provider: agreement.provider)
        application_choice = create(:application_choice, :awaiting_provider_decision, course_option: course_option)
        auth_context = ProviderAuthorisation.new(actor: provider_user)
        expect(auth_context.can_make_offer?(application_choice: application_choice)).to be_truthy
      end

      it 'is true even if user is associated with multiple providers' do
        new_provider = create(:provider)
        new_provider.provider_users << provider_user
        course_option = course_option_for_provider(provider: new_provider)
        application_choice = create(:application_choice, :awaiting_provider_decision, course_option: course_option)
        auth_context = ProviderAuthorisation.new(actor: provider_user)
        expect(auth_context.can_make_offer?(application_choice: application_choice)).to be_truthy
      end
    end

    context 'with support user' do
      it 'is true no matter what' do
        application_choice = create(:application_choice, :awaiting_provider_decision)
        auth_context = ProviderAuthorisation.new(actor: create(:support_user))
        expect(auth_context.can_make_offer?(application_choice: application_choice)).to be_truthy
      end
    end

    context 'with api key' do
      it 'is false if api key is not associated with the provider that offers the course' do
        application_choice = create(:application_choice, :awaiting_provider_decision)
        auth_context = ProviderAuthorisation.new(actor: create(:vendor_api_user))
        expect(auth_context.can_make_offer?(application_choice: application_choice)).to be_falsy
      end

      it 'is true if api key is associated with the provider that offers the course' do
        vendor_api_user = create(:vendor_api_user)
        course_option = course_option_for_provider(provider: vendor_api_user.vendor_api_token.provider)
        application_choice = create(:application_choice, :awaiting_provider_decision, course_option: course_option)
        auth_context = ProviderAuthorisation.new(actor: vendor_api_user)
        expect(auth_context.can_make_offer?(application_choice: application_choice)).to be_truthy
      end
    end
  end
end
