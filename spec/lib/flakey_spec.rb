require 'rails_helper'

# rubocop:disable Style/ClassVars
RSpec.describe 'Flakey spec' do
  @@success = false

  after { @@success = true }

  it 'eventually succeeds' do
    expect(@@success).to be true
  end
end
# rubocop:enable Style/ClassVars
