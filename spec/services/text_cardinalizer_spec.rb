require 'rails_helper'

RSpec.describe TextCardinalizer do
  it 'can return the cardinal text value of a number up to ten' do
    expect(TextCardinalizer.call(0)).to match('zero')
    expect(TextCardinalizer.call(1)).to match('one')
    expect(TextCardinalizer.call(2)).to match('two')
    expect(TextCardinalizer.call(3)).to match('three')
    expect(TextCardinalizer.call(4)).to match('four')
    expect(TextCardinalizer.call(5)).to match('five')
    expect(TextCardinalizer.call(6)).to match('six')
    expect(TextCardinalizer.call(7)).to match('seven')
    expect(TextCardinalizer.call(8)).to match('eight')
    expect(TextCardinalizer.call(9)).to match('nine')
    expect(TextCardinalizer.call(10)).to match('ten')
  end

  it 'will revert to number literal written numbers after ten' do
    expect(TextCardinalizer.call(11)).to match('11')
  end
end
