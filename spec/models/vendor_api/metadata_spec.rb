require 'rails_helper'

RSpec.describe VendorAPI::Metadata do
  subject { described_class.new }

  it { is_expected.to validate_presence_of :attribution }
  it { is_expected.to validate_presence_of :timestamp }

  describe 'validating attribution' do
    it 'is invalid when the attribution is present but invalid' do
      attribution = { full_name: nil, cold: :bananas }

      metadata = described_class.new(attribution: attribution, timestamp: Time.zone.now)

      expect(metadata).not_to be_valid
    end
  end
end
