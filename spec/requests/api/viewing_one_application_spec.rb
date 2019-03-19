describe 'GET one application' do
  let(:json_response) { JSON.parse(response.body) }

  before do
    headers = { "ACCEPT" => "application/json" }
    get "/api/applications/#{id}", headers: headers
  end

  context 'with an id matching the first application' do
    let(:id) { "3fa85f64-5717-4562-b3fc-2c963f66afa6" }

    it 'responds with a success code' do
      expect(response).to have_http_status(:ok)
    end

    it 'responds with the right application' do
      expect(json_response).to include({
        'id' => id,
        'first_name' => "Christopher"
      })
    end
  end

  context 'with an id matching the second application' do
    let(:id) { "74d1ed54-444d-4a9b-823f-9029fd1aacfc" }

    it 'responds with a success code' do
      expect(response).to have_http_status(:ok)
    end

    it 'responds with the right application' do
      expect(json_response).to include({
        'id' => id,
        'first_name' => "Alexander"
      })
    end
  end

  context 'with an id matching the third application' do
    let(:id) { "7531944b-f134-4da4-ba85-a6f990055843" }

    it 'responds with a success code' do
      expect(response).to have_http_status(:ok)
    end

    it 'responds with the right application' do
      expect(json_response).to include({
        'id' => id,
        'first_name' => "Amy"
      })
    end
  end

  context 'with an id not matching any application' do
    let(:id) { "nonsense-code" }

    it 'responds with not found' do
      expect(response).to have_http_status(:not_found)
    end

    it 'returns no application data' do
      expect(response.body).to be_empty
    end
  end
end
