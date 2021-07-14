require 'rails_helper'

RSpec.describe SupportInterface::ProviderTestDataController, type: :request do
  let!(:provider) { create(:provider) }
  let!(:course) { create(:course, :open_on_apply, provider: provider) }
  let!(:course_option) { create(:course_option, course: course) }
  let(:support_user) do
    SupportUser.new(
      email_address: 'alice@example.com',
      dfe_sign_in_uid: 'ABC',
    )
  end

  before do
    allow(SupportUser).to receive(:load_from_session).and_return(support_user)
    allow(GenerateTestApplicationsForCourses).to receive(:perform_async)
  end

  describe 'POST create' do
    before { post support_interface_provider_test_data_path(provider) }

    it 'redirects to the application choice path' do
      expect(response.status).to eq(302)
      expect(response.redirect_url).to include(support_interface_provider_applications_path(provider))
    end

    context 'when the environment is sandbox', sandbox: true do
      it 'enqueues a generation test data job' do
        expect(GenerateTestApplicationsForCourses)
          .to have_received(:perform_async)
          .exactly(100).times
      end
    end

    context 'when the environment is not sandbox' do
      it 'does not enqueue a generation test data job' do
        expect(GenerateTestApplicationsForCourses).not_to have_received(:perform_async)
      end
    end
  end
end
