require 'rails_helper'

RSpec.describe 'ProviderInterface::CandidatePool::PublishInvitesController' do
  describe 'POST /provider/find-candidates/:candidate_id/invite/:draft_invite_id/review' do
    let!(:provider_user) { create(:provider_user, :with_provider, :with_make_decisions, dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }
    let(:provider) { provider_user.providers.first }

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
      mailer = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      allow(CandidateMailer).to receive(:candidate_invite).and_return(mailer)
    end

    it 'redirects to candidate_interface_interstitial_path' do
      candidate = create(:candidate)
      application_form = create(:application_form, :completed, candidate:)
      create(:candidate_preference, application_form:)
      create(:candidate_pool_application, application_form:)
      course = create(:course, :open, provider:)

      draft_invite = create(
        :pool_invite,
        status: :draft,
        candidate:,
        application_form:,
        provider:,
        course:,
      )

      post provider_interface_candidate_pool_candidate_draft_invite_publish_invite_path(
        candidate,
        draft_invite,
      )

      expect(response).to redirect_to(provider_interface_candidate_pool_root_path)
      expect(CandidateMailer).to have_received(:candidate_invite).with(draft_invite)
    end
  end
end
