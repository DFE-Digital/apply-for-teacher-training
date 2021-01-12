require 'rails_helper'

RSpec.describe ApplyRedisConnection do
  # REDIS_URL may be set in the test environment (on CI, for example), so stub
  # its value to nil to ensure the tests below can test the right behaviour.
  before { stub_const('ENV', { 'REDIS_URL' => nil }) }

  describe '.url' do
    context 'when REDIS_URL is present in the environment' do
      before { stub_const('ENV', { 'REDIS_URL' => 'redis://redis_url/1' }) }

      it 'returns REDIS_URL' do
        expect(ApplyRedisConnection.url).to eq 'redis://redis_url/1'
      end
    end

    context 'when TEST_ENV_NUMBER is present in the environment' do
      before { stub_const('ENV', { 'TEST_ENV_NUMBER' => '1' }) }

      it 'returns local Redis with a database number TEST_ENV_NUMBER + 1' do
        expect(ApplyRedisConnection.url).to eq 'redis://localhost:6379/2'
      end
    end

    it 'returns local Redis with database number 9 if Rails environment is test' do
      allow(Rails.env).to receive(:test?).and_return true
      expect(ApplyRedisConnection.url).to eq 'redis://localhost:6379/9'
    end

    it 'returns local Redis with database number 0 in all other cases' do
      allow(Rails.env).to receive(:test?).and_return false
      expect(ApplyRedisConnection.url).to eq 'redis://localhost:6379/0'
    end
  end
end
