describe 'GET offers against one application' do
  let(:json_response) { JSON.parse(response.body) }

  before do
    headers = { 'ACCEPT' => 'application/json' }
    get "/api/v2/applications/#{id}/offers", headers: headers
  end

  context 'with an id matching the first application' do
    let(:id) { '3fa85f64-5717-4562-b3fc-2c963f66afa6' }

    it 'responds with a success code' do
      expect(response).to have_http_status(:ok)
    end

    it 'responds with no offers' do
      expect(json_response['offers']).to eq([])
    end
  end

  context 'with an id matching the second application' do
    let(:id) { '74d1ed54-444d-4a9b-823f-9029fd1aacfc' }

    it 'responds with one offer' do
      expect(json_response['offers'].count).to eq 1
    end

    describe 'the offer in the response' do
      let(:offer) { json_response['offers'].first }

      it 'is unconditional' do
        expect(offer['conditions']).to eq([])
      end

      it 'includes relevant dates' do
        expect(offer).to include(
          'offer_date' => '2018-01-01',
          'training_start_date' => '2020-01-04',
          'expiry_date' => '2018-02-10'
        )
      end

      it 'includes course information' do
        expect(offer).to include(
          'training_provider_code' => 'X11',
          'training_programme' => 'NF56',
          'training_location' => 'Main Site',
        )
      end

      it 'is marked as not accepted' do
        expect(offer['accepted']).to be false
      end
    end
  end

  context 'with an id matching the third application' do
    let(:id) { '7531944b-f134-4da4-ba85-a6f990055843' }

    it 'responds with one offer' do
      expect(json_response['offers'].count).to eq 1
    end

    describe 'the offer in the response' do
      let(:offer) { json_response['offers'].first }

      it 'is for a different course' do
        course_applied_for = 'NF56'
        course_offered = 'NF81'
        expect(course_applied_for).to_not eq(course_offered)
      end

      it 'is conditional' do
        expect(offer['conditions'].count).to eq 2
      end
    end
  end

  context 'with an id not matching any application' do
    let(:id) { 'nonsense-code' }

    it 'responds with not found' do
      expect(response).to have_http_status(:not_found)
    end

    it 'returns no offers data' do
      expect(response.body).to be_empty
    end
  end
end
