require 'rails_helper'

RSpec.describe SessionError do
  describe 'associations' do
    it { is_expected.to belong_to(:candidate).optional }
  end
end
