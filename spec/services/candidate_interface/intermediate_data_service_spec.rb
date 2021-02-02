require 'rails_helper'

RSpec.describe CandidateInterface::IntermediateDataService do
  def create_service
    described_class.new(@state_store)
  end

  before do
    @state_store = WizardStateStores::RedisStore.new(key: 'test_flow-123456')
    @state_store.delete
  end

  describe '#read' do
    it 'returns an initial empty hash' do
      service = create_service
      expect(service.read).to eq({})
    end

    it 'returns a deserialised Hash from Redis' do
      service = create_service
      data = { 'key1' => 'one', 'key2' => 'two', 'key3' => 'three' }
      @state_store.write(data.to_json)
      expect(service.read).to eq(data)
    end
  end

  describe '#write' do
    it 'merges new data over existing' do
      service = create_service
      initial_data = { 'key1' => 'one', 'key2' => 'two', 'key3' => 'three' }
      @state_store.write(initial_data.to_json)
      service.write('key3' => 'THREE', 'key4' => 'FOUR')
      expect(service.read).to eq({ 'key1' => 'one', 'key2' => 'two', 'key3' => 'THREE', 'key4' => 'FOUR' })
    end
  end
end
