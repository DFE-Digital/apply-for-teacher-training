require 'rails_helper'

RSpec.describe 'Notify Callback - POST /notify/callback', type: :request do
  let(:reference) do
    application_form = create(:application_form)
    create(:reference, feedback_status: 'feedback_requested', application_form: application_form)
  end
  let(:notify_callback_token) { ENV.fetch('GOVUK_NOTIFY_CALLBACK_API_KEY') }
  let(:headers) do
    { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{notify_callback_token}" }
  end

  it 'returns success if token matches environment variable' do
    request_body = {
      reference: "test-reference_request-#{reference.id}",
      status: 'permanent-failure',
    }.to_json

    post '/notify/callback', headers: headers, params: request_body

    expect(response).to have_http_status(:success)
  end

  it 'returns unauthorized if token is not provided' do
    post '/notify/callback'

    expect(response).to have_http_status(:unauthorized)
  end

  it 'returns unauthorized if token does not match environment variable' do
    post '/notify/callback', headers: { 'Authorization' => 'Bearer invalid-api-key' }

    expect(response).to have_http_status(:unauthorized)
  end

  it 'returns unprocessable entity if Notify reference is not provided' do
    request_body = {
      status: 'permanent-failure',
    }.to_json

    post '/notify/callback', headers: headers, params: request_body

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it 'returns unprocessable entity if Notify status is not provided' do
    request_body = {
      reference: "test-reference_request-#{reference.id}",
    }.to_json

    post '/notify/callback', headers: headers, params: request_body

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it 'returns not found if Notify reference includes unknown reference id' do
    allow(ProcessNotifyCallback).to receive(:call)
      .with(notify_reference: "test-reference_request-#{reference.id}", status: 'permanent-failure')
      .and_return(:not_found)

    request_body = {
      reference: "test-reference_request-#{reference.id}",
      status: 'permanent-failure',
    }.to_json

    post '/notify/callback', headers: headers, params: request_body

    expect(response).to have_http_status(:not_found)
  end

  it 'updates the referee status if expected Notify reference and status' do
    request_body = {
      reference: "test-reference_request-#{reference.id}",
      status: 'permanent-failure',
    }.to_json

    post '/notify/callback', headers: headers, params: request_body

    expect(reference.reload.feedback_status).to eq('email_bounced')
  end

  it 'does not update referee status if unexpected Notify reference and status' do
    request_body = {
      reference: "qa-survey_email-#{reference.id}",
      status: 'temporary-failure',
    }.to_json

    post '/notify/callback', headers: headers, params: request_body

    expect(reference.reload.feedback_status).to eq('feedback_requested')
  end
end
