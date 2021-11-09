require 'rails_helper'

# rubocop:disable Style/ClassVars
RSpec.describe 'A flaky spec' do
  @@fail = true
  after { @@fail = false }

  it 'eventually succeeds', retry: 3 do
    expect(@@fail).to be false
  end
end
# rubocop:enable Style/ClassVars
