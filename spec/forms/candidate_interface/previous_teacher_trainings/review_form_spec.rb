require 'rails_helper'

module CandidateInterface
  module PreviousTeacherTrainings
    RSpec.describe ReviewForm, type: :model do
      subject(:form) do
        described_class.new(application_form)
      end

      let(:previous_teacher_training) { create(:previous_teacher_training) }
      let(:application_form) { previous_teacher_training.application_form }

      describe '#publish!' do
        TestSuiteTimeMachine.freeze do
          it 'publishes the previous_teacher_training and deletes any other published record' do
            old_published_training_id = create(
              :previous_teacher_training,
              :published,
              application_form:,
            ).id

            expect { form.publish! }.to change { previous_teacher_training.status }.to('published')
              .and change { application_form.updated_at }.to(Time.zone.now)

            expect(PreviousTeacherTraining.exists?(old_published_training_id)).to be(false)
          end
        end
      end

      describe '#save' do
        context 'when section completed' do
          it 'marks the section completed' do
            form.completed = 'true'
            expect { form.save }.to change { application_form.previous_teacher_training_completed }.to(true)
          end
        end

        context 'when section is not completed' do
          it 'marks the section not completedcompleted' do
            form.completed = 'false'
            expect { form.save }.to change { application_form.previous_teacher_training_completed }.to(false)
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
