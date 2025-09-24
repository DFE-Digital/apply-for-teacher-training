require 'rails_helper'

module CandidateInterface
  module PreviousTeacherTrainings
    RSpec.describe DetailsForm, type: :model do
      subject(:form) do
        described_class.new(previous_teacher_training)
      end

      let(:previous_teacher_training) do
        create(:previous_teacher_training, details: nil)
      end

      describe '#save' do
        it 'saves the details on the previous_teacher_training' do
          form.details = 'details'

          expect { form.save }.to change { previous_teacher_training.details }
            .to('details')
        end

        context 'with invalid form' do
          it 'returns nil' do
            form.details = nil

            expect(form.save).to be_nil
          end
        end
      end
    end
  end
end
