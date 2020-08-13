require 'rails_helper'

RSpec.describe SafeCSV do
  it 'sanitises an array of values' do
    expect(
      SafeCSV.sanitise([123, 'hello', '=(A1,A6)']),
    ).to eq(
      [123, 'hello', '.=(A1,A6)'],
    )
  end

  it 'sanitises a single value' do
    expect(SafeCSV.sanitise('=(A1,A6)')).to eq('.=(A1,A6)')
  end
end
