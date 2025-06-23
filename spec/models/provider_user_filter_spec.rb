require 'rails_helper'

RSpec.describe ProviderUserFilter do
  describe 'associations' do
    it { is_expected.to belong_to(:provider_user) }
  end
end
