describe 'making an offer' do
  before do
    headers = { 'ACCEPT' => 'application/json' }
    patch "/api/applications/#{id}/make_offer", headers: headers
  end

  context 'with an id not matching any application' do
    let(:id) { 'nonsense-code' }

    it 'responds with JSON' do
      expect(response.content_type).to eq('application/json')
    end

    it 'responds with a not found code' do
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'with an id matching an application' do
    let(:id) { '3fa85f64-5717-4562-b3fc-2c963f66afa6' }

    it 'responds with JSON' do
      expect(response.content_type).to eq('application/json')
    end

    it 'responds ok' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns the relevant application' do
      expect(JSON.parse(response.body)).to include(
        'id' => id,
        'first_name' => 'Boris'
      )
    end
  end
end
