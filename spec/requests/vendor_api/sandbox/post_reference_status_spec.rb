require 'rails_helper'

RSpec.describe 'Vendor API - Modifying reference state (sandbox)' do
  include VendorAPISpecHelpers

  let(:reference) { create(:reference, :feedback_requested) }
  let(:currently_authenticated_provider) { reference.application_form.providers.first }
  let(:version) { '1' }
  let(:workflow_testing) { true }

  before do
    allow(HostingEnvironment).to receive(:workflow_testing?).and_return(workflow_testing)
  end

  describe 'POST /reference/:id/success' do
    let(:path) { "/api/v#{version}/reference/#{reference.id}/success" }

    it 'returns a 200 OK response' do
      post_api_request(path)
      expect(response).to have_http_status(:ok)
    end

    VendorAPI::VERSIONS.each_key do |version|
      context "on specific version #{version}" do
        let(:version) { version.gsub('pre', '') }

        it 'returns a 200 OK response' do
          post_api_request(path)
          expect(response).to have_http_status(:ok)
        end
      end
    end

    it 'changes the reference to `feedback_provided`' do
      post_api_request(path)
      expect(reference.reload.feedback_status).to eq('feedback_provided')
    end

    it 'fills in various bits' do
      post_api_request(path)
      reference.reload

      expect(reference.feedback_provided_at).not_to be_nil
      expect(reference.feedback).not_to be_nil
      expect(reference.safeguarding_concerns).not_to be_nil
      expect(reference.relationship_correction).not_to be_nil
    end

    context 'when the reference is not in the `feedback_requested` state' do
      let(:reference) { create(:reference, :feedback_provided) }

      it 'returns a 422 Unprocessable Entity response' do
        post_api_request(path)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not change the reference' do
        expect { post_api_request(path) }.not_to(change { reference.reload.feedback_status })
      end
    end

    context 'when the reference does not exist' do
      let(:path) { "/api/v#{version}/reference/#{reference.id + 1}/success" }

      it 'returns a 404 Not Found response' do
        post_api_request(path)
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the reference is not for the current provider' do
      let(:currently_authenticated_provider) { create(:provider) }

      it 'returns a 404 Not Found response' do
        post_api_request(path)
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when not in sandbox' do
      let(:workflow_testing) { false }

      it 'returns a 404 Not Found response' do
        post_api_request(path)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /reference/:id/failure' do
    let(:path) { "/api/v#{version}/reference/#{reference.id}/failure" }

    it 'returns a 200 OK response' do
      post_api_request(path)
      expect(response).to have_http_status(:ok)
    end

    VendorAPI::VERSIONS.each_key do |version|
      context "on specific version #{version}" do
        let(:version) { version.gsub('pre', '') }

        it 'returns a 200 OK response' do
          post_api_request(path)
          expect(response).to have_http_status(:ok)
        end
      end
    end

    it 'changes the reference to `feedback_refused`' do
      post_api_request(path)
      expect(reference.reload.feedback_status).to eq('feedback_refused')
    end

    it 'fills in various bits' do
      post_api_request(path)
      reference.reload

      expect(reference.feedback_refused_at).not_to be_nil
      expect(reference.feedback).to be_nil
    end

    context 'when the reference is not in the `feedback_requested` state' do
      let(:reference) { create(:reference, :feedback_provided) }

      it 'returns a 422 Unprocessable Entity response' do
        post_api_request(path)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not change the reference' do
        expect { post_api_request(path) }.not_to(change { reference.reload.feedback_status })
      end
    end

    context 'when the reference does not exist' do
      let(:path) { "/api/v#{version}/reference/#{reference.id + 1}/failure" }

      it 'returns a 404 Not Found response' do
        post_api_request(path)
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the reference is not for the current provider' do
      let(:currently_authenticated_provider) { create(:provider) }

      it 'returns a 404 Not Found response' do
        post_api_request(path)
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when not in sandbox' do
      let(:workflow_testing) { false }

      it 'returns a 404 Not Found response' do
        post_api_request(path)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
