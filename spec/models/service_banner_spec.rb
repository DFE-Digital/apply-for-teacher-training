require 'rails_helper'

RSpec.describe ServiceBanner do
  subject(:banner) { described_class.new }

  describe 'enums' do
    it {
      expect(banner).to define_enum_for(:status)
        .backed_by_column_of_type(:string)
        .with_values(draft: 'draft', published: 'published', used: 'used')
    }

    it {
      expect(banner).to define_enum_for(:interface)
        .backed_by_column_of_type(:string)
        .with_values(apply: 'apply', manage: 'manage', support_console: 'support_console')
    }
  end

  describe 'defaults' do
    it 'defaults status to draft' do
      banner = described_class.new
      expect(banner.status).to eq('draft')
    end
  end
end
