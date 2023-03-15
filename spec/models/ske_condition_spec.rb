require 'rails_helper'

RSpec.describe SkeCondition do
  describe '#text' do
    it 'returns the subject in a human readable title' do
      build(:ske_condition)

      expect(build(:ske_condition).text).to eq('Mathematics subject knowledge enhancement course')
    end
  end
end
