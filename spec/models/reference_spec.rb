require 'rails_helper'

RSpec.describe Reference, type: :model do
  subject { build(:reference) }

  describe 'a valid reference' do
    it { is_expected.to validate_presence_of :email_address }
    it { is_expected.to validate_length_of(:email_address).is_at_most(100) }
  end

  describe '#complete?' do
    it 'is complete when there is a reference' do
      expect(build(:reference, feedback: 'abc')).to be_complete
    end

    it 'is incomplete when there is no reference' do
      expect(build(:reference, feedback: nil)).not_to be_complete
    end
  end
end
