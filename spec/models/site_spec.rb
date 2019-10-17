require 'rails_helper'

RSpec.describe Site, type: :model do
  subject { create(:site) }

  describe 'a valid site' do
    it { is_expected.to validate_presence_of :code }
    it { is_expected.to validate_presence_of :name }
  end
end
