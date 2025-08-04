require 'rails_helper'

RSpec.describe Pool::InviteDeclineReason do
  subject(:decline_reason) { described_class.new }

  describe 'associations' do
    it { is_expected.to belong_to(:invite).class_name('Pool::Invite') }
  end

  describe 'enums' do
    it {
      expect(decline_reason).to define_enum_for(:status)
        .with_values(draft: 'draft', published: 'published')
        .with_default(:draft)
        .backed_by_column_of_type(:string)
    }
  end

  describe '#reason_only_salaried?' do
    it 'returns false when reason is not set' do
      decline_reason = build(:pool_invite_decline_reason, reason: nil)

      expect(decline_reason).not_to be_reason_only_salaried
    end

    it 'returns true when reason is only_salaried' do
      decline_reason = build(:pool_invite_decline_reason, reason: 'only_salaried')

      expect(decline_reason).to be_reason_only_salaried
    end
  end

  describe '#reason_location_not_convenient?' do
    it 'returns false when reason is not set' do
      decline_reason = build(:pool_invite_decline_reason, reason: nil)

      expect(decline_reason).not_to be_reason_location_not_convenient
    end

    it 'returns true when reason is location_not_convenient' do
      decline_reason = build(:pool_invite_decline_reason, reason: 'location_not_convenient')

      expect(decline_reason).to be_reason_location_not_convenient
    end
  end

  describe '#reason_no_longer_interested?' do
    it 'returns false when reason is not set' do
      decline_reason = build(:pool_invite_decline_reason, reason: nil)

      expect(decline_reason).not_to be_reason_no_longer_interested
    end

    it 'returns true when reason is no_longer_interested' do
      decline_reason = build(:pool_invite_decline_reason, reason: 'no_longer_interested')

      expect(decline_reason).to be_reason_no_longer_interested
    end
  end
end
