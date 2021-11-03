require 'rails_helper'

RSpec.describe 'A flaky spec' do
  it 'randomly succeeds', retry: 3 do
    expect(rand(2)).to eq(1)
  end
end
