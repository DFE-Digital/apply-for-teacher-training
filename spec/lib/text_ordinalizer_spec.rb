require 'rails_helper'

RSpec.describe TextOrdinalizer do
  it 'can return the text value of a number up to ten' do
    expect(described_class.call(0)).to match('zeroth')
    expect(described_class.call(1)).to match('first')
    expect(described_class.call(2)).to match('second')
    expect(described_class.call(3)).to match('third')
    expect(described_class.call(4)).to match('fourth')
    expect(described_class.call(5)).to match('fifth')
    expect(described_class.call(6)).to match('sixth')
    expect(described_class.call(7)).to match('seventh')
    expect(described_class.call(8)).to match('eighth')
    expect(described_class.call(9)).to match('ninth')
    expect(described_class.call(10)).to match('tenth')
  end

  it 'will revert to "Nth" written numbers after ten' do
    expect(described_class.call(11)).to match('11th')
  end
end
