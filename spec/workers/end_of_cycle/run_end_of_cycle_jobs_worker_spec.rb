require 'rails_helper'

RSpec.describe EndOfCycle::RunEndOfCycleJobsWorker do
  before do
    allow(EndOfCycle::CancelUnsubmittedApplicationsWorker).to receive(:perform_async).with(true)
    allow(EndOfCycle::CloseCoursesOnInvites).to receive(:perform_async).with(true)
    allow(EndOfCycle::RejectByDefaultWorker).to receive(:perform_async).with(true)
    allow(EndOfCycle::CancelReferenceRequestsWorker).to receive(:perform_async)
    allow(EndOfCycle::DeclineByDefaultWorker).to receive(:perform_async).with(true)
    allow(EndOfCycle::WinterRejectByDefaultWorker).to receive(:perform_async).with(true)
    allow(EndOfCycle::WinterDeclineByDefaultWorker).to receive(:perform_async).with(true)
  end

  describe '#perform' do
    context 'in mid-cycle' do
      it 'does not run any jobs' do
        date = current_timetable.apply_opens_at + 2.months
        travel_temporarily_to(date) do
          described_class.new.perform
          expect(EndOfCycle::CancelUnsubmittedApplicationsWorker).not_to have_received(:perform_async)
          expect(EndOfCycle::CloseCoursesOnInvites).not_to have_received(:perform_async)
          expect(EndOfCycle::RejectByDefaultWorker).not_to have_received(:perform_async)
          expect(EndOfCycle::DeclineByDefaultWorker).not_to have_received(:perform_async)
          expect(EndOfCycle::CancelReferenceRequestsWorker).not_to have_received(:perform_async)
          expect(EndOfCycle::WinterRejectByDefaultWorker).not_to have_received(:perform_async)
          expect(EndOfCycle::WinterDeclineByDefaultWorker).not_to have_received(:perform_async)
        end
      end
    end

    context 'after apply deadline, before reject by default date' do
      it 'runs only apply deadline related jobs' do
        date = current_timetable.apply_deadline_at + 1.minute
        travel_temporarily_to(date) do
          described_class.new.perform
          # These jobs run on the apply deadline
          expect(EndOfCycle::CancelUnsubmittedApplicationsWorker).to have_received(:perform_async).with(true)
          expect(EndOfCycle::CloseCoursesOnInvites).to have_received(:perform_async).with(true)
          # Not these
          expect(EndOfCycle::RejectByDefaultWorker).not_to have_received(:perform_async)
          expect(EndOfCycle::DeclineByDefaultWorker).not_to have_received(:perform_async)
          expect(EndOfCycle::CancelReferenceRequestsWorker).not_to have_received(:perform_async)
          expect(EndOfCycle::WinterRejectByDefaultWorker).not_to have_received(:perform_async)
          expect(EndOfCycle::WinterDeclineByDefaultWorker).not_to have_received(:perform_async)
        end
      end
    end

    context 'after reject by default, before decline by default date' do
      it 'runs apply deadline related jobs and reject by default job' do
        date = current_timetable.reject_by_default_at + 1.minute
        travel_temporarily_to(date) do
          described_class.new.perform
          # These jobs run on the apply deadline
          expect(EndOfCycle::CancelUnsubmittedApplicationsWorker).to have_received(:perform_async).with(true)
          expect(EndOfCycle::CloseCoursesOnInvites).to have_received(:perform_async).with(true)
          # And the reject by default worker
          expect(EndOfCycle::RejectByDefaultWorker).to have_received(:perform_async).with(true)
          # Not these
          expect(EndOfCycle::CancelReferenceRequestsWorker).not_to have_received(:perform_async)
          expect(EndOfCycle::DeclineByDefaultWorker).not_to have_received(:perform_async)
          expect(EndOfCycle::WinterRejectByDefaultWorker).not_to have_received(:perform_async)
          expect(EndOfCycle::WinterDeclineByDefaultWorker).not_to have_received(:perform_async)
        end
      end
    end

    context 'after decline by default' do
      it 'runs apply deadline related jobs, reject by default job, and decline by default job' do
        date = current_timetable.decline_by_default_at + 1.minute
        travel_temporarily_to(date) do
          described_class.new.perform
          # Apply deadline jobs
          expect(EndOfCycle::CancelUnsubmittedApplicationsWorker).to have_received(:perform_async).with(true)
          expect(EndOfCycle::CloseCoursesOnInvites).to have_received(:perform_async).with(true)
          # And the reject by default worker
          expect(EndOfCycle::RejectByDefaultWorker).to have_received(:perform_async).with(true)
          # And the decline by default worker related jobs
          expect(EndOfCycle::DeclineByDefaultWorker).to have_received(:perform_async).with(true)
          expect(EndOfCycle::CancelReferenceRequestsWorker).to have_received(:perform_async)
          # But not the winter jobs
          expect(EndOfCycle::WinterRejectByDefaultWorker).not_to have_received(:perform_async)
          expect(EndOfCycle::WinterDeclineByDefaultWorker).not_to have_received(:perform_async)
        end
      end
    end

    context 'into the next cycle, after the previous cycle winter reject by default at' do
      it 'runs the winter jobs only' do
        date = current_timetable.winter_reject_by_default_at + 1.minute
        travel_temporarily_to(date) do
          described_class.new.perform
          # Apply deadline jobs
          expect(EndOfCycle::CancelUnsubmittedApplicationsWorker).to have_received(:perform_async).with(true)
          expect(EndOfCycle::CloseCoursesOnInvites).to have_received(:perform_async).with(true)
          # And the reject by default worker
          expect(EndOfCycle::RejectByDefaultWorker).to have_received(:perform_async).with(true)
          # And the decline by default worker related jobs
          expect(EndOfCycle::DeclineByDefaultWorker).to have_received(:perform_async).with(true)
          expect(EndOfCycle::CancelReferenceRequestsWorker).to have_received(:perform_async)
          # But not the winter jobs
          expect(EndOfCycle::WinterRejectByDefaultWorker).not_to have_received(:perform_async)
          expect(EndOfCycle::WinterDeclineByDefaultWorker).not_to have_received(:perform_async)
        end
      end
    end
  end
end
