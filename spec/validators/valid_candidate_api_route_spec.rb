require 'rails_helper'

RSpec.describe ValidCandidateApiRoute do
  let(:request) { instance_double(ActionDispatch::Request, params: params) }

  context 'for a known version' do
    let(:params) { { api_version: 'v1.1' } }
    
    it 'is valid' do
      expect(described_class.matches?(request)).to be(true)
    end  
  end

  context 'for a nil version' do
    let(:params) { Hash.new }
    
    it 'is valid' do
      expect(described_class.matches?(request)).to be(true)
    end  
  end

  context 'for an unknown version' do
    let(:params) { { api_version: 'v3.1' } }
    
    it 'is not valid' do
      expect(described_class.matches?(request)).to be(false)
    end  
  end
end
