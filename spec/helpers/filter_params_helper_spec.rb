require 'rails_helper'

RSpec.describe FilterParamsHelper, type: :helper do
  describe '#compact_params' do
    let(:params) { ActionController::Parameters.new(params_hash) }
    let(:result) { compact_params(params) }

    context 'when the params contain only string values' do
      let(:params_hash) { { name: 'Bob', age: '21' } }

      it 'has no affect on the params' do
        expect(result[:name]).to eq('Bob')
        expect(result[:age]).to eq('21')
      end
    end

    context 'when the params contain arrays with non-present values' do
      let(:params_hash) { { name: 'Bob', sports: [''] } }

      it 'removes the non-present values from the array params' do
        expect(result[:name]).to eq('Bob')
        expect(result[:sports]).to eq([])
      end
    end

    context 'when the params contain arrays with some present values' do
      let(:params_hash) { { name: 'Bob', sports: ['', 'Golf'] } }

      it 'only keeps the present values in the array params' do
        expect(result[:name]).to eq('Bob')
        expect(result[:sports]).to eq(['Golf'])
      end
    end
  end
end
