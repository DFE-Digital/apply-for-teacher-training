require 'rails_helper'

RSpec.describe BatchDelivery do
  describe '#each' do
    it 'raises NotImplementedError' do
      relation = create_list(:candidate, 2)

      expect { described_class.new(relation:).each }.to raise_error NotImplementedError
    end
  end
end
