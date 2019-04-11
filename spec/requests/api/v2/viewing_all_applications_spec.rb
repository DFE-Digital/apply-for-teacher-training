describe 'GET applications' do
  let(:json_response) { JSON.parse(response.body) }

  before do
    headers = { "ACCEPT" => "application/json" }
    get '/api/v2/applications', headers: headers
  end

  it 'responds with JSON' do
    expect(response.content_type).to eq("application/json")
  end

  it 'responds with a success code' do
    expect(response).to have_http_status(:ok)
  end

  it 'contains three applications' do
    expect(json_response['applications'].count).to eq(3)
  end

  context 'first application' do
    let(:first_application) { json_response['applications'].first }

    it 'has an id' do
      expect(first_application['id'])
        .to_not be_blank
    end

    it 'has a first name' do
      expect(first_application['first_name'])
        .to_not be_blank
    end

    it 'has an email' do
      expect(first_application['email'])
        .to_not be_blank
    end
  end
end
