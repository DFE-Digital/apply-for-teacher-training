require 'rails_helper'

RSpec.describe 'GET /check', type: :request do
  it 'returns 200' do
    get '/check'
    expect(response).to have_http_status(200)
  end
end
