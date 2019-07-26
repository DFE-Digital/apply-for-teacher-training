require 'rails_helper'

describe ErrorSummaryHelper do
  describe '#field_anchor_link' do
    context 'given a ActiveModel record and a field_name' do
      let(:model_name_mock) { double(param_key: 'active_model') }
      let(:active_model_mock) { double(model_name: model_name_mock) }

      it 'returns active_model_field_name' do
        result = helper.field_anchor_link(active_model_mock, :field_name)
        expect(result).to eq('#active_model_field_name')
      end
    end
  end
end
