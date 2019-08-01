require 'rails_helper'

describe FormErrorSummaryHelper do
  describe '#field_anchor_link' do
    context 'given a model_name and field' do
      let(:naming_mock) do
        instance_double(ActiveModel::Name, param_key: 'example_model')
      end

      it 'returns the correct anchor link for that model & field' do
        result = helper.field_anchor_link(
          model_name: naming_mock,
          field: :field_name
        )
        expect(result).to eq('#example_model_field_name')
      end
    end
  end
end
