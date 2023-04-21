require 'rails_helper'

RSpec.describe ReferenceCondition do
  describe '#structured_condition?' do
    it 'returns true' do
      expect(build(:reference_condition)).to be_structured_condition
    end
  end
end
