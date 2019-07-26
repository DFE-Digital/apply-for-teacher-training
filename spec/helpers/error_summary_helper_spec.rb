require 'rails_helper'

describe ErrorSummaryHelper do
  describe '#field_anchor_link' do
    context 'given an ActiveModel and a field_name' do
      class ExampleModel; include ActiveModel::Model; end

      it 'returns example_model_field_name' do
        result = helper.field_anchor_link(ExampleModel.new, :field_name)
        expect(result).to eq('#example_model_field_name')
      end
    end
  end
end
