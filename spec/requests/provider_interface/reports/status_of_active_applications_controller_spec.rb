require 'rails_helper'
RSpec.describe ProviderInterface::Reports::StatusOfActiveApplicationsController, type: :request do
  let(:provider_user) { create(:provider_user, :with_dfe_sign_in, :with_make_decisions) }
  let(:provider) { provider_user.providers.first }

  before do
    allow(DfESignInUser).to receive(:load_from_session)
                        .and_return(DfESignInUser.new(email_address: provider_user.email_address,
                                                      dfe_sign_in_uid: provider_user.dfe_sign_in_uid,
                                                      first_name: provider_user.first_name,
                                                      last_name: provider_user.last_name))
  end

  describe 'GET show' do
    context 'when the report dashboard feature flag is turned off' do
      before do
        FeatureFlag.deactivate(:provider_reports_dashboard)
      end

      it 'redirects to the reports page' do
        get provider_interface_reports_provider_status_of_active_applications_path(provider_id: provider)

        expect(response.status).to eq(302)
        expect(response.redirect_url).to eq(provider_interface_reports_url)
      end
    end
  end
end
