require 'rails_helper'

RSpec.describe Subject, type: :model do
  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:code) }
  end
end
