require 'rails_helper'

module CandidateInterface
  module PreviousTeacherTrainings
    RSpec.describe ReviewForm, type: :model do
      subject(:form) do
        described_class.new(previous_teacher_training)
      end

      let(:previous_teacher_training) { create(:previous_teacher_training) }

      describe '#formatted_dates' do
        it 'formats the started_at and ended_at' do
          started_at = previous_teacher_training.started_at
          ended_at = previous_teacher_training.ended_at
          expected = "From #{started_at.to_fs(:month_and_year)} to #{ended_at.to_fs(:month_and_year)}"

          expect(form.formatted_dates).to eq(expected)
        end

        context 'without ended_at' do
          let(:previous_teacher_training) { create(:previous_teacher_training, ended_at: nil) }

          it 'formats the started_at' do
            started_at = previous_teacher_training.started_at
            expected = "From #{started_at.to_fs(:month_and_year)}"

            expect(form.formatted_dates).to eq(expected)
          end
        end
      end

      describe '#save' do
        context 'when section completed' do
          it 'publishes the previous_teacher_training and marks the section completed' do
            form.completed = 'true'
            published_training_id = create(
              :previous_teacher_training,
              :published,
              application_form: previous_teacher_training.application_form,
            ).id

            expect { form.save }.to change { previous_teacher_training.status }
              .to('published')
              .and change { previous_teacher_training.application_form.previous_teacher_training_completed_at }.from(nil)

            expect(PreviousTeacherTraining.exists?(published_training_id)).to be(false)
          end
        end

        context 'when section is not completed' do
          let(:previous_teacher_training) do
            create(:previous_teacher_training, application_form:)
          end
          let(:application_form) { create(:application_form, previous_teacher_training_completed_at: Time.zone.now) }

          it 'publishes the previous_teacher_training and marks the section completed' do
            form.completed = 'false'
            published_training_id = create(
              :previous_teacher_training,
              :published,
              application_form:,
            ).id

            expect { form.save }.to change { previous_teacher_training.status }
              .to('published')
              .and change { application_form.previous_teacher_training_completed_at }.to(nil)

            expect(PreviousTeacherTraining.exists?(published_training_id)).to be(false)
          end
        end

        context 'with invalid form' do
          it 'returns nil' do
            form.completed = nil

            expect(form.save).to be_nil
          end
        end
      end
    end
  end
end
