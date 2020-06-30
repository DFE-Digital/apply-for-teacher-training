require 'rails_helper'

RSpec.describe TextOrdinalizer do
  it 'can return the text value of a number up to ten' do
    expect(TextOrdinalizer.call(0)).to match('zeroth')
    expect(TextOrdinalizer.call(1)).to match('first')
    expect(TextOrdinalizer.call(2)).to match('second')
    expect(TextOrdinalizer.call(3)).to match('third')
    expect(TextOrdinalizer.call(4)).to match('fourth')
    expect(TextOrdinalizer.call(5)).to match('fifth')
    expect(TextOrdinalizer.call(6)).to match('sixth')
    expect(TextOrdinalizer.call(7)).to match('seventh')
    expect(TextOrdinalizer.call(8)).to match('eighth')
    expect(TextOrdinalizer.call(9)).to match('ninth')
    expect(TextOrdinalizer.call(10)).to match('tenth')
  end

  it 'will revert to "Nth" written numbers after ten' do
    expect(TextOrdinalizer.call(11)).to match('11th')
  end
end
