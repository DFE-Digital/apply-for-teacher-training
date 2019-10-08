require 'rails_helper'

RSpec.describe VendorApi::Metadata do
  subject { VendorApi::Metadata.new }

  describe 'a valid metadata' do
    it { is_expected.to validate_presence_of :attribution }
    it { is_expected.to validate_presence_of :timestamp }
  end
end
