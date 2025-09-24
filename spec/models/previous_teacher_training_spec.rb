require 'rails_helper'

RSpec.describe PreviousTeacherTraining do
  describe 'associations' do
    it { is_expected.to belong_to(:application_form) }
  end

  describe '#create_draft_dup' do
    it 'creates a draft duplication of a published previous_teacher_training' do
      previous_teacher_training = create(:previous_teacher_training, status: 'published')

      expect { previous_teacher_training.create_draft_dup! }.to change(described_class.draft, :count).by(1)
    end
  end

  describe '#reviewable?' do
    context 'when started is yes' do
      it 'returns true if all attributes are populated' do
        previous_teacher_training = create(:previous_teacher_training)

        expect(previous_teacher_training.reviewable?).to be(true)
      end

      it 'returns false if not all attributes are populated' do
        previous_teacher_training = create(:previous_teacher_training, started_at: nil)

        expect(previous_teacher_training.reviewable?).to be(false)
      end
    end

    context 'when started is no' do
      it 'returns true if all attributes are not populated' do
        previous_teacher_training = create(:previous_teacher_training, :not_started)

        expect(previous_teacher_training.reviewable?).to be(true)
      end

      it 'returns false if not all attributes are populated' do
        previous_teacher_training = create(
          :previous_teacher_training,
          :not_started,
          started_at: Time.zone.now,
        )

        expect(previous_teacher_training.reviewable?).to be(false)
      end
    end
  end

  describe '#formatted_dates' do
    it 'formats the started_at and ended_at' do
      previous_teacher_training = build(:previous_teacher_training)
      started_at = previous_teacher_training.started_at
      ended_at = previous_teacher_training.ended_at
      expected = "From #{started_at.to_fs(:month_and_year)} to #{ended_at.to_fs(:month_and_year)}"

      expect(previous_teacher_training.formatted_dates).to eq(expected)
    end
  end
end
