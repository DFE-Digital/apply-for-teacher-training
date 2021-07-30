require 'rails_helper'

RSpec.describe ProviderInterface::WorkHistoryAndUnpaidExperienceItemComponent do
  subject(:experience_item) { described_class.new(item: item) }

  describe '#title' do
    context 'when the item is a voluntery role' do
      let(:item) { build(:application_volunteering_experience, role: 'Teacher', working_pattern: 'Full time') }

      it 'includes (unpaid) for any volunteer roles' do
        expect(experience_item.title).to eq('Teacher - Full time (unpaid)')
      end
    end

    context 'when the item is an explained break' do
      let(:item) { build(:application_work_history_break, reason: 'No reason') }

      it 'includes (unpaid) for any volunteer roles' do
        expect(experience_item.title).to start_with('Break (')
      end
    end
  end

  describe '#break' do
    context 'when ApplicationWorkHistoryBreak or BreakPlaceHolder' do
      let(:item) { build(:application_work_history_break) }

      it 'returns true' do
        expect(experience_item.break?).to eq(true)
      end
    end

    context 'when not ApplicationWorkHistoryBreak or BreakPlaceHolder' do
      let(:item) { build(:application_volunteering_experience) }

      it 'returns false' do
        expect(experience_item.break?).to eq(false)
      end
    end
  end
end
