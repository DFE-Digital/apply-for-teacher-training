require 'rails_helper'

RSpec.describe Pool::Dismissal do
  describe 'associations' do
    it { is_expected.to belong_to(:candidate) }
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to belong_to(:dismissed_by).class_name('ProviderUser') }
  end
end
