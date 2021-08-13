require 'rails_helper'

RSpec.describe TextCardinalizer do
  it 'can return the cardinal text value of a number up to ten' do
    expect(described_class.call(0)).to match('zero')
    expect(described_class.call(1)).to match('one')
    expect(described_class.call(2)).to match('two')
    expect(described_class.call(3)).to match('three')
    expect(described_class.call(4)).to match('four')
    expect(described_class.call(5)).to match('five')
    expect(described_class.call(6)).to match('six')
    expect(described_class.call(7)).to match('seven')
    expect(described_class.call(8)).to match('eight')
    expect(described_class.call(9)).to match('nine')
    expect(described_class.call(10)).to match('ten')
  end

  it 'will revert to number literal written numbers after ten' do
    expect(described_class.call(11)).to match('11')
  end
end
