require 'rails_helper'

RSpec.describe SupportInterface::ProviderTestDataController do
  let!(:provider) { create(:provider) }
  let!(:course) { create(:course, :open, provider:) }
  let!(:course_option) { create(:course_option, course:) }
  let(:support_user) do
    SupportUser.new(
      email_address: 'alice@example.com',
      dfe_sign_in_uid: 'ABC',
    )
  end

  before do
    allow(SupportUser).to receive(:load_from_session).and_return(support_user)
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
