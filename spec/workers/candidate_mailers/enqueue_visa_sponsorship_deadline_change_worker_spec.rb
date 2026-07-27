require 'rails_helper'

module CandidateMailers
  RSpec.describe EnqueueVisaSponsorshipDeadlineChangeWorker do
    describe '#perform' do
      it 'calls SendVisaSponsorshipDeadlineChangeWorker worker' do
        course = create(:course, :open)
        create_list(:application_choice, 2)
        allow(UnsubmittedApplicationChoicesForCourse).to(
          receive(:call).with(course.id).and_return(ApplicationChoice.all),
        )

        expect { described_class.new.perform(course.id) }.to enqueue_job(SendVisaSponsorshipDeadlineChangeWorker)
      end

      context 'when course is closed' do
        it 'does not call SendVisaSponsorshipDeadlineChangeWorker worker' do
          course = create(:course, :closed)
          create_list(:application_choice, 2)
          allow(UnsubmittedApplicationChoicesForCourse).to(
            receive(:call).with(course.id).and_return(ApplicationChoice.all),
          )

          expect { described_class.new.perform(course.id) }.not_to enqueue_job(SendVisaSponsorshipDeadlineChangeWorker)
        end
      end
    end
  end
end
