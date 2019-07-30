require 'rails_helper'

describe FormErrorSummaryHelper do
  describe '#field_anchor_link' do
    context 'given a field_name' do
      let(:naming_mock) { double(param_key: 'example_model') }

      it 'returns the correct anchor link for that model & field' do
        result = helper.field_anchor_link(naming_mock, :field_name)
        expect(result).to eq('#example_model_field_name')
      end
    end
  end
end
