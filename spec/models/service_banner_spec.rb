require 'rails_helper'

RSpec.describe ServiceBanner do
  describe 'enums' do
    it 'defines the correct status values' do
      expect(described_class.statuses).to eq(
        'draft' => 'draft',
        'published' => 'published',
        'used' => 'used',
      )
    end

    it 'responds to enum helper methods' do
      banner = described_class.new

      expect(banner).to respond_to(:draft?)
      expect(banner).to respond_to(:published?)
      expect(banner).to respond_to(:used?)
      expect(banner).to respond_to(:draft!)
      expect(banner).to respond_to(:published!)
      expect(banner).to respond_to(:used!)
    end
  end

  describe 'defaults' do
    it 'defaults status to draft' do
      banner = described_class.new
      expect(banner.status).to eq('draft')
    end
  end
end
