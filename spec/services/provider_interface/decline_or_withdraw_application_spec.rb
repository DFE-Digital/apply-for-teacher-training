require 'rails_helper'

RSpec.describe ProviderInterface::DeclineOrWithdrawApplication do
  describe '#save!' do
    let(:resolver) { instance_double(ResolveUCASMatch, call: true) }

    before { allow(ResolveUCASMatch).to receive(:new).and_return(resolver) }

    it 'declines applications which are under offer' do
      application_choice = create(:application_choice, :with_offer)
      provider = application_choice.course_option.provider
      permitted_user = create(:provider_user, :with_make_decisions, providers: [provider])

      expect(described_class.new(application_choice: application_choice, actor: permitted_user).save!).to be true

      expect(application_choice.reload.declined_at).not_to be nil
      expect(application_choice).to be_declined
      expect(application_choice).not_to be_withdrawn
      expect(ResolveUCASMatch).not_to have_received(:new)
    end

    it 'withdraws applications which are withdrawable' do
      application_choice = create(:application_choice, :awaiting_provider_decision)
      provider = application_choice.course_option.provider
      permitted_user = create(:provider_user, :with_make_decisions, providers: [provider])

      expect(described_class.new(application_choice: application_choice, actor: permitted_user).save!).to be true

      expect(application_choice.reload.withdrawn_at).not_to be nil
      expect(application_choice).to be_withdrawn
      expect(application_choice).not_to be_declined
    end

    it 'resolves UCAS matches when withdrawing' do
      application_choice = create(:application_choice, :awaiting_provider_decision)
      provider = application_choice.course_option.provider
      permitted_user = create(:provider_user, :with_make_decisions, providers: [provider])

      described_class.new(application_choice: application_choice, actor: permitted_user).save!

      expect(ResolveUCASMatch).to have_received(:new).with(application_choice: application_choice)
      expect(resolver).to have_received(:call)
    end

    it 'returns false when the application is not under offer and is not withdrawable' do
      application_choice = create(:application_choice, :withdrawn)
      provider = application_choice.course_option.provider
      permitted_user = create(:provider_user, :with_make_decisions, providers: [provider])

      expect(described_class.new(application_choice: application_choice, actor: permitted_user).save!).to be false
    end

    it 'raises when the provider user cannot make decisions' do
      application_choice = create(:application_choice, :awaiting_provider_decision)
      provider = application_choice.course_option.provider
      user = create(:provider_user, providers: [provider])

      expect {
        described_class.new(application_choice: application_choice, actor: user).save!
      }.to raise_error(ProviderAuthorisation::NotAuthorisedError)
    end

    it 'emails the candidate about the withdrawn application' do
      application_choice = create(:application_choice, :awaiting_provider_decision)
      provider = application_choice.course_option.provider
      permitted_user = create(:provider_user, :with_make_decisions, providers: [provider])
      email_service_class = ProviderInterface::SendCandidateWithdrawnOnRequestEmail
      email_service = instance_double(email_service_class, call: true)
      allow(email_service_class).to receive(:new).and_return(email_service)

      described_class.new(application_choice: application_choice, actor: permitted_user).save!

      expect(email_service_class).to have_received(:new).with(application_choice: application_choice)
      expect(email_service).to have_received(:call)
    end
  end
end
