require 'rails_helper'

RSpec.describe 'Notify Callback - POST /integrations/notify/callback', type: :request do
  let(:application_form) { create(:application_form) }
  let(:reference) do
    create(:reference, feedback_status: 'feedback_requested', application_form: application_form)
  end
  let(:notify_callback_token) { ENV.fetch('GOVUK_NOTIFY_CALLBACK_API_KEY') }
  let(:headers) do
    { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{notify_callback_token}" }
  end

  around do |example|
    ClimateControl.modify HOSTING_ENVIRONMENT_NAME: 'test' do
      example.run
    end
  end

  it 'returns success if token matches environment variable' do
    request_body = {
      reference: "test-reference_request-#{reference.id}",
      status: 'permanent-failure',
    }.to_json

    post '/integrations/notify/callback', headers: headers, params: request_body

    expect(response).to have_http_status(:success)
  end

  it 'returns unauthorized if token is not provided' do
    post '/integrations/notify/callback'

    expect(response).to have_http_status(:unauthorized)
  end

  it 'returns unauthorized if token does not match environment variable' do
    post '/integrations/notify/callback', headers: { 'Authorization' => 'Bearer invalid-api-key' }

    expect(response).to have_http_status(:unauthorized)
  end

  it 'returns unprocessable entity if Notify reference is not provided' do
    request_body = {
      status: 'permanent-failure',
    }.to_json

    post '/integrations/notify/callback', headers: headers, params: request_body

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it 'returns unprocessable entity if Notify status is not provided' do
    request_body = {
      reference: "test-reference_request-#{reference.id}",
    }.to_json

    post '/integrations/notify/callback', headers: headers, params: request_body

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it 'returns success if Notify reference is nil' do
    request_body = {
      reference: nil,
      status: 'permanent-failure',
    }.to_json

    post '/integrations/notify/callback', headers: headers, params: request_body

    expect(response).to have_http_status(:success)
  end

  it 'returns unprocessable entity if Notify status is nil' do
    request_body = {
      reference: "test-reference_request-#{reference.id}",
      status: nil,
    }.to_json

    post '/integrations/notify/callback', headers: headers, params: request_body

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it 'returns not found if Notify reference includes unknown reference id' do
    process_notify_callback = instance_double('ProcessNotifyCallback')
    allow(ProcessNotifyCallback).to receive(:new).and_return(process_notify_callback)
    allow(process_notify_callback).to receive(:call)
    allow(process_notify_callback).to receive(:not_found?).and_return(true)

    request_body = {
      reference: "test-reference_request-#{reference.id}",
      status: 'permanent-failure',
    }.to_json

    post '/integrations/notify/callback', headers: headers, params: request_body

    expect(response).to have_http_status(:not_found)
  end

  it 'updates the referee status if expected Notify reference and status' do
    request_body = {
      reference: "test-reference_request-#{reference.id}",
      status: 'permanent-failure',
    }.to_json

    post '/integrations/notify/callback', headers: headers, params: request_body

    expect(reference.reload.feedback_status).to eq('email_bounced')
  end

  it 'does not update referee status if unexpected Notify reference and status' do
    request_body = {
      reference: "qa-survey_email-#{reference.id}",
      status: 'temporary-failure',
    }.to_json

    post '/integrations/notify/callback', headers: headers, params: request_body

    expect(reference.reload.feedback_status).to eq('feedback_requested')
  end

  it 'sends a new referee request email to the candidate' do
    request_body = {
      reference: "test-reference_request-#{reference.id}",
      status: 'permanent-failure',
    }.to_json

    post '/integrations/notify/callback', headers: headers, params: request_body

    candidate_email = application_form.candidate.email_address
    open_email(candidate_email)

    expect(current_email.subject).to end_with(t('candidate_mailer.new_referee_request.email_bounced.subject', referee_name: reference.name))
  end
end
