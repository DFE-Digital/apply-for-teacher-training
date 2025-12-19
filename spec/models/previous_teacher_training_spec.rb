require 'rails_helper'

RSpec.describe PreviousTeacherTraining do
  describe 'associations' do
    it { is_expected.to belong_to(:application_form) }
    it { is_expected.to belong_to(:provider).optional }
    it { is_expected.to belong_to(:duplicate_previous_teacher_training).class_name('PreviousTeacherTraining').optional }

    it { is_expected.to have_one(:source_previous_teacher_training).class_name('PreviousTeacherTraining') }
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

  describe '#make_published' do
    context 'when the previous teacher training is published' do
      let(:previous_teacher_training) { create(:previous_teacher_training, status: 'published') }

      it 'does not change the previous teacher training status' do
        expect { previous_teacher_training.make_published }.not_to change(previous_teacher_training, :status)
      end
    end

    context 'when the previous teacher training is not published' do
      let(:previous_teacher_training) { create(:previous_teacher_training) }
      let(:application_form) { previous_teacher_training.application_form }

      it 'changes the previous teacher training status to published' do
        expect { previous_teacher_training.make_published }.to change(previous_teacher_training, :status).to('published')
      end

      context 'when the previous teacher training has a duplicate record' do
        let(:source_previous_teacher_training) do
          create(
            :previous_teacher_training,
            application_form:,
            status: 'published',
            duplicate_previous_teacher_training: previous_teacher_training,
          )
        end

        before { source_previous_teacher_training }

        it 'deletes the source previous teacher training record' do
          expect { previous_teacher_training.make_published }.to change(
            application_form.previous_teacher_trainings, :count
          ).from(2).to(1)
          expect(application_form.previous_teacher_trainings).to contain_exactly(previous_teacher_training)
        end
      end

      context 'when the duplicate previous teacher training record started attribute is "no"' do
        let(:previous_teacher_training) { create(:previous_teacher_training, started: 'no') }

        before do
          create_list(
            :previous_teacher_training,
            3,
            application_form:,
            status: 'published',
          )
        end

        it 'deletes all pre-existing previous teacher training records' do
          expect { previous_teacher_training.make_published }.to change(
            application_form.previous_teacher_trainings, :count
          ).from(5).to(1)
          expect(application_form.previous_teacher_trainings).to contain_exactly(previous_teacher_training)
        end
      end
    end
  end
end
