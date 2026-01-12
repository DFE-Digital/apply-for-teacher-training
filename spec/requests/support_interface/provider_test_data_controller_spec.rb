require 'rails_helper'

RSpec.describe SupportInterface::ProviderTestDataController do
  include DfESignInHelpers

  let!(:provider) { create(:provider) }
  let!(:course) { create(:course, :open, provider:) }
  let!(:course_option) { create(:course_option, course:) }
  let(:support_user) do
    create(
      :support_user,
      dfe_sign_in_uid: 'DFE_SIGN_IN_UID',
    )
  end

  before do
    support_user_exists_dsi(dfe_sign_in_uid: support_user.dfe_sign_in_uid)
    get auth_dfe_support_callback_path
  end

  describe 'POST create' do
    before do
      allow(GenerateTestApplicationsForCourses).to receive(:perform_async)
      post support_interface_provider_test_data_path(provider)
    end

    context 'when the environment is sandbox', :sandbox do
      it 'redirects to the application choice path' do
        expect(response).to have_http_status(:found)
        expect(response.redirect_url).to include(support_interface_provider_applications_path(provider))
      end

      it 'enqueues a generation test data job' do
        expect(GenerateTestApplicationsForCourses)
          .to have_received(:perform_async)
          .exactly(100).times
      end
    end

    context 'when the environment is not sandbox' do
      it 'responds with 403 Forbidden' do
        expect(response).to have_http_status(:forbidden)
      end

      it 'does not enqueue a generation test data job' do
        expect(GenerateTestApplicationsForCourses).not_to have_received(:perform_async)
      end
    end
  end
end
