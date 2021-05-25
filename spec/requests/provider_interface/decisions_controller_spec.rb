require 'rails_helper'

RSpec.describe ProviderInterface::DecisionsController, type: :request do
  include DfESignInHelpers

  let(:provider_user) { create(:provider_user, :with_dfe_sign_in, :with_make_decisions) }
  let(:provider) { provider_user.providers.first }
  let(:application_form) { build(:application_form, :minimum_info) }
  let(:course) { build(:course, :open_on_apply, provider: provider) }
  let(:course_option) { build(:course_option, course: course) }

  let!(:application_choice) do
    create(:application_choice, :withdrawn,
           application_form: application_form,
           course_option: course_option)
  end

  before do
    allow(DfESignInUser).to receive(:load_from_session)
      .and_return(
        DfESignInUser.new(
          email_address: provider_user.email_address,
          dfe_sign_in_uid: provider_user.dfe_sign_in_uid,
          first_name: provider_user.first_name,
          last_name: provider_user.last_name,
        ),
      )
  end

  describe 'if application choice is not in a pending decision state' do
    context 'GET new' do
      it 'responds with 302' do
        get new_provider_interface_application_choice_decision_path(application_choice)

        expect(response.status).to eq(302)
      end
    end

    context 'POST create' do
      it 'responds with 302' do
        post provider_interface_application_choice_decision_path(application_choice)

        expect(response.status).to eq(302)
      end
    end
  end

  describe 'validation errors' do
    let(:withdraw_offer) do
      instance_double(
        WithdrawOffer,
        valid?: false,
        save: false,
        offer_withdrawal_reason: nil,
        errors: instance_double(ActiveModel::Errors, any?: true, messages: { offer_withdrawal_reason: ["can't be blank"] }),
        model_name: ActiveModel::Name.new(WithdrawOffer),
      )
    end

    before { application_choice.update!(status: 'awaiting_provider_decision') }

    it 'tracks validation errors on create' do
      wizard_class = ProviderInterface::OfferWizard
      wizard = instance_double(
        wizard_class,
        decision: nil,
        valid_for_current_step?: false,
        errors: instance_double(ActiveModel::Errors, any?: true, messages: { decision: ["can't be blank"] }),
        model_name: ActiveModel::Name.new(wizard_class),
      )

      allow(ProviderInterface::OfferWizard).to receive(:new).and_return(wizard)

      expect {
        post provider_interface_application_choice_decision_path(application_choice)
      }.to change(ValidationError, :count).by(1)
    end

    it 'tracks validation errors on confirm withdraw offer' do
      allow(WithdrawOffer).to receive(:new).and_return(withdraw_offer)

      expect {
        post provider_interface_application_choice_confirm_withdraw_offer_path(application_choice)
      }.to change(ValidationError, :count).by(1)
    end

    it 'tracks validation errors on withdraw offer' do
      allow(WithdrawOffer).to receive(:new).and_return(withdraw_offer)

      expect {
        post provider_interface_application_choice_withdraw_offer_path(application_choice)
      }.to change(ValidationError, :count).by(1)
    end
  end
end
