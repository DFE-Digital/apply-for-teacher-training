require 'rails_helper'

module CandidateInterface
  module PreviousTeacherTrainings
    RSpec.describe StartForm, type: :model do
      include Rails.application.routes.url_helpers

      subject(:form) do
        described_class.new(previous_teacher_training)
      end

      let(:previous_teacher_training) { build(:previous_teacher_training, started: nil) }

      describe '#options' do
        it 'returns the form options' do
          expect(form.options).to eq(
            [
              StartForm::Started.new(value: 'yes', name: 'Yes'),
              StartForm::Started.new(value: 'no', name: 'No'),
            ],
          )
        end
      end

      describe '#save' do
        context 'when option is yes' do
          it 'saves started enum to previous_teacher_training' do
            form.started = 'yes'

            expect { form.save }.to change { previous_teacher_training.started }.to('yes')
          end
        end

        context 'when option is no after user when through all the steps' do
          it 'saves started enum to previous_teacher_training and clears the rest' do
            form.started = 'no'

            expect { form.save }.to change { previous_teacher_training.started }
              .to('no')
              .and change { previous_teacher_training.provider_name }.to(nil)
              .and change { previous_teacher_training.started_at }.to(nil)
              .and change { previous_teacher_training.ended_at }.to(nil)
              .and change { previous_teacher_training.details }.to(nil)
          end
        end

        context 'with invalid form' do
          it 'returns nil' do
            form.started = nil

            expect(form.save).to be_nil
          end
        end
      end

      describe '#next_path' do
        context 'when started is yes' do
          let(:previous_teacher_training) { create(:previous_teacher_training, started: 'yes') }

          it 'returns the back_path if return_to is present' do
            params = { return_to: 'review' }

            expect(form.next_path(params)).to eq(
              candidate_interface_previous_teacher_training_path(previous_teacher_training),
            )
          end

          it 'returns the provider name path if return_to is not present' do
            params = {}
            expect(form.next_path(params)).to eq(
              new_candidate_interface_previous_teacher_training_name_path(previous_teacher_training),
            )
          end
        end

        context 'when started is no' do
          let(:previous_teacher_training) { create(:previous_teacher_training, started: 'no') }

          it 'returns the review path' do
            params = {}
            expect(form.next_path(params)).to eq(
              candidate_interface_previous_teacher_training_path(previous_teacher_training),
            )
          end
        end
      end
    end
  end
end
