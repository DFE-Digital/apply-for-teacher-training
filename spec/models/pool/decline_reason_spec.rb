require 'rails_helper'

RSpec.describe Pool::DeclineReason do
  describe 'associations' do
    it { is_expected.to belong_to(:invite).class_name('Pool::Invite') }
  end

  describe 'enums' do
    it {
      expect(subject).to define_enum_for(:status)
        .with_values(draft: 'draft', published: 'published')
        .with_default(:draft)
        .backed_by_column_of_type(:string)
    }
  end
end
