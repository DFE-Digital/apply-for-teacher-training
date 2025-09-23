require 'rails_helper'

module CandidateInterface
  module PreviousTeacherTrainings
    RSpec.describe DatesForm, type: :model do
      subject(:form) do
        described_class.new(previous_teacher_training)
      end
      let(:previous_teacher_training) { create(:previous_teacher_training) }

      describe 'validations' do
        context 'when started_at is nil' do
          let(:previous_teacher_training) { build(:previous_teacher_training, started_at: nil) }

          it 'is invalid' do
            expect(form.valid?).to be(false)
            expect(form.errors[:started_at]).to contain_exactly('Enter the date that you started the training course')
          end
        end

        context 'when start_date_month is invalid' do
          let(:previous_teacher_training) { build(:previous_teacher_training) }

          it 'is invalid' do
            form.start_date_month = ''
            form.start_date_year = 2005

            expect(form.valid?).to be(false)
            expect(form.errors[:started_at]).to contain_exactly('Enter the month that you started the training course')
          end
        end

        context 'when start_date_year is invalid' do
          let(:previous_teacher_training) { build(:previous_teacher_training) }

          it 'is invalid' do
            form.start_date_month = 1
            form.start_date_year = ''

            expect(form.valid?).to be(false)
            expect(form.errors[:started_at]).to contain_exactly('Enter the year that you started the training course')
          end
        end

        context 'when started_at is after ended_at' do
          let(:previous_teacher_training) do
            build(
              :previous_teacher_training,
              started_at: Time.zone.now,
              ended_at: 2.years.ago,
            )
          end

          it 'is invalid' do
            expect(form.valid?).to be(false)
            expect(form.errors[:started_at]).to contain_exactly(
              'Enter a course start date that is before the date you have left the course',
            )
          end
        end

        context 'when ended_at is nil' do
          let(:previous_teacher_training) { build(:previous_teacher_training, ended_at: nil) }

          it 'is invalid' do
            expect(form.valid?).to be(false)
            expect(form.errors[:ended_at]).to contain_exactly('Enter the date that you left the training course')
          end
        end

        context 'when end_date_month is invalid' do
          let(:previous_teacher_training) { build(:previous_teacher_training) }

          it 'is invalid' do
            form.end_date_month = ''
            form.end_date_year = 2005

            expect(form.valid?).to be(false)
            expect(form.errors[:ended_at]).to contain_exactly('Enter the month that you left the training course')
          end
        end

        context 'when end_date_year is invalid' do
          let(:previous_teacher_training) { build(:previous_teacher_training) }

          it 'is invalid' do
            form.end_date_month = 1
            form.end_date_year = ''

            expect(form.valid?).to be(false)
            expect(form.errors[:ended_at]).to contain_exactly('Enter the year that you left the training course')
          end
        end
      end

      describe '#save' do
        it 'saves started_at and ended_at on previous_teacher_training' do
          started_at = 2.years.ago
          ended_at = 1.year.ago
          form.start_date_month = started_at.month
          form.start_date_year = started_at.year
          form.end_date_month = ended_at.month
          form.end_date_year = ended_at.year
          expected_started_at = Time.zone.local(started_at.year, started_at.month)
          expected_ended_at = Time.zone.local(ended_at.year, ended_at.month)

          expect { form.save }.to change { previous_teacher_training.started_at }
            .to(expected_started_at)
            .and change { previous_teacher_training.ended_at }.to(expected_ended_at)
        end

        context 'with invalid form' do
          let(:previous_teacher_training) { create(:previous_teacher_training, started_at: nil) }

          it 'returns nil' do
            form.start_date_month = nil

            expect(form.save).to be_nil
          end
        end
      end
    end
  end
end
