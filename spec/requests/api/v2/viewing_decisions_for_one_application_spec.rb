describe 'GET decisions against one application' do
  subject { response }

  let(:json_response) { JSON.parse(subject.body) }

  before do
    headers = { 'ACCEPT' => 'application/json' }
    get "/api/v2/applications/#{id}/decisions", headers: headers
  end

  context 'with an id matching the first application' do
    let(:id) { '3fa85f64-5717-4562-b3fc-2c963f66afa6' }

    it { is_expected.to have_http_status(:ok) }

    it 'responds with no decisions' do
      expect(json_response['decisions']).to eq([])
    end
  end

  context 'with an id matching the second application' do
    let(:id) { '74d1ed54-444d-4a9b-823f-9029fd1aacfc' }

    it { is_expected.to have_http_status(:ok) }

    it 'responds with one decision' do
      expect(json_response['decisions'].count).to eq(1)
    end

    it 'includes a candidate withdrawal in the response' do
      expect(json_response['decisions'].first).to include(
        'owner' => 'candidate',
        'type' => 'withdrawal',
        'date' => '2019-03-12T14:00:00.578Z'
      )
    end
  end

  context 'with an id matching the third application' do
    let(:id) { '7531944b-f134-4da4-ba85-a6f990055843' }

    it { is_expected.to have_http_status(:ok) }

    it 'responds with one decision' do
      expect(json_response['decisions'].count).to eq(1)
    end

    it 'includes a provider rejection in the response' do
      expect(json_response['decisions'].first).to include(
        'owner' => 'provider',
        'type' => 'rejection',
        'reason' => 'does not meet minimum GCSE English requirement',
        'date' => '2019-03-15T11:00:00.000Z'
      )
    end
  end

  context 'with an id for a fourth example' do
    let(:id) { 'provider-offer-example' }

    it { is_expected.to have_http_status(:ok) }

    it 'includes a provider offer in the response' do
      expect(json_response['decisions'].first).to eq(
        'owner' => 'provider',
        'type' => 'offer',
        'training_programme' => 'NF81',
        'training_location' => 'Main Site',
        'conditions' => [
          'completion of professional skills test',
          'two weeks\' work experience in a primary school'
        ],
        'date' => '2019-03-15T11:00:00.000Z',
        'expiry_date' => '2019-03-26T00:00:00.000Z'
      )
    end
  end

  context 'with an id for a fifth example' do
    let(:id) { 'candidate-accept-example' }

    it { is_expected.to have_http_status(:ok) }

    it 'includes two decisions in the response' do
      expect(json_response['decisions'].count).to eq(2)
    end

    it 'includes a provider offer in the response' do
      expect(json_response['decisions']).to include(
        'owner' => 'provider',
        'type' => 'offer',
        'training_programme' => 'NF81',
        'training_location' => 'Main Site',
        'conditions' => [],
        'date' => '2019-03-15T11:00:00.000Z',
        'expiry_date' => '2019-03-26T00:00:00.000Z'
      )
    end

    it 'includes a candidate acceptance in the response' do
      expect(json_response['decisions']).to include(
        'owner' => 'candidate',
        'type' => 'accept',
        'date' => '2019-03-16T11:00:00.000Z'
      )
    end
  end

  context 'with an id for a sixth example' do
    let(:id) { 'candidate-reject-example' }

    it { is_expected.to have_http_status(:ok) }

    it 'includes a provider offer in the response' do
      expect(json_response['decisions']).to include(
        'owner' => 'provider',
        'type' => 'offer',
        'training_programme' => 'NF81',
        'training_location' => 'Main Site',
        'conditions' => [],
        'date' => '2019-03-15T11:00:00.000Z',
        'expiry_date' => '2019-03-26T00:00:00.000Z'
      )
    end

    it 'includes a candidate withdrawal in the response' do
      expect(json_response['decisions']).to include(
        'owner' => 'candidate',
        'type' => 'withdrawal',
        'date' => '2019-03-15T10:00:00.000Z'
      )
    end
  end

  context 'with an id not matching any application' do
    let(:id) { 'nonsense-code' }

    it { is_expected.to have_http_status(:not_found) }

    it 'returns no data' do
      expect(subject.body).to be_empty
    end
  end
end
