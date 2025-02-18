require 'rails_helper'

RSpec.describe Pool::Invite do
  describe 'associations' do
    it { is_expected.to belong_to(:candidate) }
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to belong_to(:invited_by).class_name('ProviderUser') }
    it { is_expected.to belong_to(:course) }
  end
end
