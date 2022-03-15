require 'rails_helper'

RSpec.describe WorkHistoryAndUnpaidExperienceItemComponent do
  subject(:experience_item) { described_class.new(item: item) }

  describe '#title' do
    context 'when the item is a voluntary role' do
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

  describe '#unexplained_break?' do
    context 'when BreakPlaceholder' do
      let(:item) { build(:application_work_history_break) }

      before { allow(item).to receive(:is_a?).with(WorkHistoryWithBreaks::BreakPlaceholder).and_return(true) }

      it 'returns true' do
        expect(experience_item.unexplained_break?).to be(true)
      end
    end

    context 'when ApplicationWorkHistoryBreak' do
      let(:item) { build(:application_work_history_break) }

      it 'returns false' do
        expect(experience_item.unexplained_break?).to be(false)
      end
    end
  end
end
