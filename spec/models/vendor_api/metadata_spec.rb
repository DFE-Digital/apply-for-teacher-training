require 'rails_helper'

RSpec.describe VendorApi::Metadata do
  subject { VendorApi::Metadata.new }

  it { is_expected.to validate_presence_of :attribution }
  it { is_expected.to validate_presence_of :timestamp }

  describe 'validating attribution' do
    it 'is invalid when the attribution is present but invalid' do
      attribution = { full_name: nil, cold: :bananas }

      metadata = VendorApi::Metadata.new(attribution: attribution, timestamp: Time.zone.now)

      expect(metadata).not_to be_valid
    end
  end
end
