# TODO: import this automagically for /api folder
require 'rails_helper'

describe 'GET applications', type: :request do
  before do
    headers = { "ACCEPT" => "application/json" }
    get '/api/applications', headers: headers
  end

  it 'responds with a success code' do
    expect(response).to have_http_status(:ok)
  end

  it 'contains three applications' do
    expect(JSON.parse(response.body).count).to eq(3)
  end

  context 'first application' do
    it 'has an id' do
      expect(JSON.parse(response.body).first['id'])
        .to_not be_blank
    end

    it 'has a first name' do
      expect(JSON.parse(response.body).first['first_name'])
        .to_not be_blank
    end

    it 'has an email' do
      expect(JSON.parse(response.body).first['email'])
        .to_not be_blank
    end
  end
end
