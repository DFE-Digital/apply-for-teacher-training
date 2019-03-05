# TODO: import this automagically for /api folder
require 'rails_helper'

describe 'GET applications', type: :request do
  it 'responds with a success code' do
    get '/api/applications'

    expect(response).to have_http_status(:ok)
  end
end
