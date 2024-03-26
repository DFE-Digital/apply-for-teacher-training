require 'rails_helper'

RSpec.describe SkeCondition do
  describe '#text' do
    it 'returns the subject in a human readable title' do
      build(:ske_condition)

      expect(build(:ske_condition).text).to eq('Mathematics subject knowledge enhancement course')
    end
  end

  describe 'validation' do
    before { @ske_condition = create(:ske_condition) }

    it 'is invalid when SKE length is not in list of permissible values' do
      @ske_condition.length = '13'
      expect(@ske_condition.valid?).to be(false)
    end
  end
end
