require 'rails_helper'

RSpec.describe OneLoginAuth do
  describe 'associations' do
    it { is_expected.to belong_to(:candidate) }
  end
end
