require 'rails_helper'

RSpec.describe 'GET /candidate-api/:versions/candidates/:candidate_id' do
  include CandidateAPISpecHelper

  versions = %w[v1.1 v1.2 v1.3]

  versions.each do |version|
    context "for version #{version}" do
      it 'does not allow access to the API from other data users' do
        service_api_token = ServiceAPIUser.test_data_user.create_magic_link_token!
        candidate = create(:candidate)
        candidate_id_param = "C#{candidate.id}"

        get_api_request "/candidate-api/#{version}/candidates/#{candidate_id_param}", token: service_api_token
        expect(response).to have_http_status(:unauthorized)
        expect(parsed_response).to be_valid_against_openapi_schema('UnauthorizedResponse', version.to_s)
      end

      it 'allows access to the API for Candidate users' do
        candidate = create(:candidate)
        candidate_id_param = "C#{candidate.id}"

        get_api_request "/candidate-api/#{version}/candidates/#{candidate_id_param}", token: candidate_api_token

        expect(response).to have_http_status(:success)
      end

      it 'allows access to the API for Teacher Success users' do
        candidate = create(:candidate)
        candidate_id_param = "C#{candidate.id}"

        get_api_request "/candidate-api/#{version}/candidates/#{candidate_id_param}", token: teacher_success_api_token

        expect(response).to have_http_status(:success)
      end

      it 'conforms to the API spec' do
        candidate = create(:candidate)
        candidate_id_param = "C#{candidate.id}"

        get_api_request "/candidate-api/#{version}/candidates/#{candidate_id_param}", token: candidate_api_token

        expect(parsed_response).to be_valid_against_openapi_schema('CandidateDetail', version.to_s)
        expect(parsed_response.dig('data', 'id')).to eq(candidate_id_param.to_s)
      end

      it 'returns applications for the candidate' do
        candidate = create(:candidate)
        candidate_id_param = "C#{candidate.id}"
        create_list(:completed_application_form, 2, candidate:)

        get_api_request "/candidate-api/#{version}/candidates/#{candidate_id_param}", token: candidate_api_token

        application_forms_response = parsed_response.dig('data', 'attributes', 'application_forms')

        expect(application_forms_response.count).to eq(2)
      end

      it "returns a NotFound error if the candidate doesn't exist" do
        get_api_request "/candidate-api/#{version}/candidates/C123", token: candidate_api_token

        expect(response).to have_http_status(:not_found)
        expect(parsed_response).to be_valid_against_openapi_schema('NotFoundResponse', version.to_s)
      end
    end
  end
end
