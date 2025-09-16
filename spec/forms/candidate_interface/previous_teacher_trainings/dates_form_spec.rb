require 'rails_helper'

module CandidateInterface
  module PreviousTeacherTrainings
    RSpec.describe DatesForm, type: :model do
      subject(:form) do
        described_class.new(previous_teacher_training)
      end

      let(:previous_teacher_training) do
        create(:previous_teacher_training, started_at: nil, ended_at: nil)
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
          it 'returns nil' do
            form.start_date_month = nil

            expect(form.save).to be_nil
          end
        end
      end
    end
  end
end
